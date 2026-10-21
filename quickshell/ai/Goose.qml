pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

//  goose ACP client
//
// Drives `goose acp` as a long-lived child process and speaks the Agent
// Client Protocol (ACP) to it: JSON-RPC 2.0, one message per line, over
// stdin/stdout. This is the transport + session layer for AI.qml; the panel
// owns all presentation and only talks to the properties/functions here.
//
// Lifecycle differs from the other Process users in this shell (grim,
// hyprctl, brightnessctl in Screenshot/Hyprview/Backlight): those are
// short-lived one-shots, whereas goose is expected to stay up for the whole
// session. It is therefore started on demand the first time a prompt is sent,
// restarted automatically if it dies, and never left running while idle.
//
Singleton {
    id: root

    //  Configuration ─
    // Command used to launch the agent. `goose` must be on PATH; ACP itself
    // is enabled by the `acp` subcommand.
    readonly property list<string> command: ["goose", "acp"]

    // Working directory handed to session/new. Required by the protocol and
    // also what makes goose's builtin tools resolve relative paths sensibly.
    property string cwd: Quickshell.env("HOME") || "/"

    //  State ─
    // Connection lifecycle, as seen by the panel:
    //   idle        -> process not running, nothing sent yet
    //   connecting  -> process up, initialize in flight
    //   ready       -> initialized and a session exists, prompts accepted
    //   error       -> handshake or session creation failed, see lastError
    enum Status { Idle, Connecting, Ready, Error }

    property int status: Goose.Idle
    property string lastError: ""
    property string sessionId: ""
    // Set while a session/prompt is outstanding, cleared on its response.
    property bool busy: false

    // Streaming transcript. `messages` is the rendered model (role + text);
    // `liveText` accumulates the in-flight agent response so the panel can
    // show tokens as they arrive. Kept as plain data, not bound straight into
    // visual items, so a burst of chunks doesn't drive a repaint per chunk.
    property var messages: []
    property string liveText: ""

    // Emitted whenever `messages`/`liveText` change. The panel connects to
    // this and throttles its own repaint against it rather than watching the
    // properties directly, which would repaint once per streamed chunk.
    signal transcriptChanged()

    readonly property bool connected: root.status === Goose.Ready

    //  JSON-RPC plumbing ─
    // Requests awaiting a response, keyed by id. ACP is strictly
    // request/response plus server-pushed notifications, so this never grows
    // beyond a handful of in-flight entries.
    property var _pending: ({})
    property int _nextId: 1
    // In-flight tool calls, keyed by toolCallId. Their title/tool name arrive
    // on the opening `tool_call` and must survive until the terminal
    // `tool_call_update` that actually reports completion.
    property var _toolCalls: ({})

    function _send(method, params, replyCb) {
        if (!proc.running) {
            if (replyCb)
                replyCb({ code: -32000, message: "goose acp is not running" }, null);
            return;
        }
        const id = root._nextId++;
        if (replyCb)
            root._pending[id] = replyCb;
        // One JSON object per line; goose frames on newlines.
        proc.write(JSON.stringify({
            jsonrpc: "2.0",
            id: id,
            method: method,
            params: params || {}
        }) + "\n");
    }

    // Notifications are fire-and-forget (no id, no response), used for
    // session/cancel.
    function _notify(method, params) {
        if (!proc.running)
            return;
        proc.write(JSON.stringify({
            jsonrpc: "2.0",
            method: method,
            params: params || {}
        }) + "\n");
    }

    function _fail(message) {
        root.lastError = message;
        root.status = Goose.Error;
        console.warn("Goose ACP:", message);
    }

    function _request(method, params, replyCb) {
        root._send(method, params, function (err, result) {
            if (err) {
                root._fail(method + " failed: " + (err.message || JSON.stringify(err)));
                return;
            }
            if (replyCb)
                replyCb(result);
        });
    }

    //  Handshake ─
    // Idempotent: safe to call from every send().
    function ensureConnected() {
        if (root.status === Goose.Connecting || root.status === Goose.Ready)
            return;
        root.lastError = "";
        root.status = Goose.Connecting;
        if (!proc.running)
            proc.running = true;
        // If the process was already up (e.g. a previous handshake failed),
        // continue from wherever we are rather than waiting for a start.
        else
            root.initialize();
    }

    function initialize() {
        root._request("initialize", {
            protocolVersion: 1,
            // We don't implement fs read/write or terminal callbacks, so
            // advertise none of them: goose will do its own file I/O instead
            // of asking us to proxy it through the client.
            clientCapabilities: {
                fs: {
                    readTextFile: false,
                    writeTextFile: false
                }
            }
        }, function (result) {
            if (!result || !result.agentCapabilities) {
                root._fail("initialize returned no agent capabilities");
                return;
            }
            root.initialized = true;
            // session/list is only valid after initialize, so the sidebar
            // refreshes here rather than when the panel opens.
            root.refreshSessions();
            root.createSession();
        });
    }

    //  Past sessions ─
    // Surfaced from goose's own store via ACP rather than the sessions.db
    // SQLite file: the protocol path is stable across goose versions and
    // avoids reading a database the agent holds open. Entries are the raw
    // SessionInfo records, most recently updated first.
    property var sessions: []
    property bool sessionsLoading: false
    // True while a session/load replay is streaming into the transcript, so
    // the view can show that history is arriving rather than looking idle.
    property bool loadingHistory: false
    // False until the initialize response lands; session/list is invalid before.
    property bool initialized: false
    // Emitted when `sessions` changes. Named `sessionsUpdated` rather than
    // `sessionsChanged`: QML already auto-generates a change signal for the
    // `sessions` property, and declaring that name is a duplicate override.
    signal sessionsUpdated()

    function refreshSessions() {
        if (!proc.running) {
            // Spawning the agent just to enumerate sessions would cost the full
            // extension-loading handshake; the panel does that on demand.
            return;
        }
        root.sessionsLoading = true;
        root._request("session/list", {}, function (result) {
            root.sessionsLoading = false;
            const list = (result && result.sessions) || [];
            // session/list comes back oldest-first; newest-first is what a
            // history sidebar wants.
            root.sessions = list.slice().sort(function (a, b) {
                return (b.updatedAt || "").localeCompare(a.updatedAt || "");
            });
            root.sessionsUpdated();
        });
    }

    // Replaces the current conversation with a stored one. The agent replays
    // the whole session as ordinary session/update notifications, so no
    // transcript parsing is needed here: _onSessionUpdate rebuilds it.
    function openSession(sessionId) {
        if (root.busy || !sessionId)
            return;
        const match = root.sessions.find(s => s.sessionId === sessionId);
        root.messages = [];
        root.liveText = "";
        root._toolCalls = ({});
        root.loadingHistory = true;
        root.transcriptChanged();

        root._request("session/load", {
            sessionId: sessionId,
            // Required by the protocol, like session/new. The stored session's
            // own cwd is reused when known so its relative paths still resolve.
            cwd: (match && match.cwd) || root.cwd,
            mcpServers: []
        }, function (result) {
            root.loadingHistory = false;
            root.sessionId = sessionId;
            root.status = Goose.Ready;
            // A load can end mid-stream; flush anything still buffered.
            root._commitLive();
        });
    }

    // Starts a fresh conversation, leaving the old one stored.
    function newSession() {
        if (root.busy)
            return;
        root.messages = [];
        root.liveText = "";
        root._toolCalls = ({});
        root.transcriptChanged();
        if (root.status === Goose.Ready) {
            root.createSession();
        } else {
            root.ensureConnected();
        }
    }

    function createSession() {
        root._request("session/new", {
            cwd: root.cwd,
            // Required by the protocol; empty means "no extra MCP servers
            // beyond goose's own configured extensions".
            mcpServers: []
        }, function (result) {
            if (!result || !result.sessionId) {
                root._fail("session/new returned no sessionId");
                return;
            }
            root.sessionId = result.sessionId;
            root.status = Goose.Ready;
        });
    }

    //  Public API
    // Appends the user's turn and kicks off a prompt. Returns false if the
    // text was empty or a turn is already in flight.
    function send(text) {
        const trimmed = (text || "").trim();
        if (!trimmed || root.busy)
            return false;

        root._append("user", trimmed);
        root.busy = true;
        root.liveText = "";
        // Set the prompt *before* kicking the handshake: ensureConnected() can
        // reach Ready synchronously when the process is already up, and
        // flushPending() would then find nothing queued and drop this turn.
        root.pendingPrompt = trimmed;
        root.ensureConnected();
        // Only push the queued turn along ourselves if the handshake is already
        // complete; otherwise onStatusChanged does it when it lands.
        if (root.status === Goose.Ready)
            root.flushPending();
        return true;
    }

    // The message queued for the next prompt. Set before the handshake can
    // complete so send() works on the very first keystroke; consumed by
    // flushPending() once the session is ready.
    property string pendingPrompt: ""

    function flushPending() {
        if (root.status !== Goose.Ready || !root.pendingPrompt)
            return;
        const text = root.pendingPrompt;
        root.pendingPrompt = "";
        root._prompt(text);
    }

    function _prompt(text) {
        root._request("session/prompt", {
            sessionId: root.sessionId,
            prompt: [
                {
                    type: "text",
                    text: text
                }
            ]
        }, function (result) {
            // The response carries the stop reason once the turn is over; the
            // actual text already arrived via session/update notifications.
            root.busy = false;
            const stop = result && result.stopReason ? result.stopReason : "end_turn";
            if (stop !== "end_turn" && stop !== "max_tokens" && stop !== "max_turn_requests")
                root._append("system", "[" + stop + "]");
            root._commitLive();
        });
    }

    function cancel() {
        if (!root.sessionId)
            return;
        root._notify("session/cancel", {
            sessionId: root.sessionId
        });
    }

    // Clears the local transcript. Note this does not end the agent-side
    // session: for a fresh conversation context, createSession() again.
    function clear() {
        root.messages = [];
        root.liveText = "";
        root._toolCalls = ({});
        root.transcriptChanged();
    }

    //  Transcript helpers
    function _append(role, text) {
        const next = root.messages.slice();
        next.push({
            role: role,
            text: text,
            toolName: "",
            status: ""
        });
        root.messages = next;
        root.transcriptChanged();
    }

    // Moves the streamed buffer into a permanent agent message. Called when a
    // turn ends, so the panel can render completed and in-flight turns with
    // different styling.
    function _commitLive() {
        if (root.liveText) {
            root._append("assistant", root.liveText);
            root.liveText = "";
        }
        root.transcriptChanged();
    }

    //  Incoming message dispatch ─
    function _dispatch(obj) {
        // Responses carry an id we issued; notifications never do.
        if (obj.id !== undefined && obj.id !== null) {
            const cb = root._pending[obj.id];
            if (cb) {
                delete root._pending[obj.id];
                cb(obj.error || null, obj.result);
            }
            return;
        }

        if (obj.method === "session/update")
            root._onSessionUpdate(obj.params);
        else if (obj.method === "_goose/unstable/session/update")
            root._onSessionUpdate(obj.params);
        else if (obj.method)
            root._onAgentRequest(obj);
    }

    function _onSessionUpdate(params) {
        if (!params || !params.update)
            return;
        const update = params.update;

        switch (update.sessionUpdate) {
        case "agent_message_chunk":
            if (update.content && update.content.type === "text") {
                root.liveText += update.content.text;
                root.transcriptChanged();
            }
            break;
        case "agent_thought_chunk":
            // Reasoning is streamed separately; ignored for now rather than
            // mixed into the visible reply.
            break;
        case "user_message_chunk":
            // Normally an echo of the prompt we just sent (already shown by
            // send()), so it is skipped. During a session/load replay there is
            // no local copy, so those chunks are what rebuilds the user side
            // of the transcript.
            if (root.loadingHistory && update.content && update.content.type === "text") {
                // A user turn closes whatever the assistant was saying: during
                // a replay there is no prompt response to mark turn boundaries,
                // so this is the only signal that one assistant block ended.
                root._commitLive();
                root._append("user", update.content.text);
            }
            break;
        case "tool_call":
        case "tool_call_update":
            root._onToolCall(update);
            break;
        default:
            break;
        }
    }

    function _onToolCall(update) {
        const id = update.toolCallId || "";
        // A tool call arrives as an initial `tool_call` (which carries title,
        // rawInput and the tool name) followed by one or more
        // `tool_call_update`s that only carry status/output. Remember the
        // intro under its id so the terminal update can name the tool: the
        // updates alone have no title and would render as a bare "tool".
        const meta = (update._meta && update._meta.goose && update._meta.goose.toolCall) || {};
        if (update.sessionUpdate === "tool_call") {
            root._toolCalls[id] = {
                title: update.title || meta.toolName || update.kind || "tool",
                toolName: meta.toolName || "",
                extensionName: meta.extensionName || ""
            };
            return;
        }

        const state = (update.status || "").toString();
        if (state !== "completed" && state !== "failed")
            return;

        const known = root._toolCalls[id] || {};
        delete root._toolCalls[id];
        root._appendTool({
            title: known.title || update.title || "tool",
            toolName: known.toolName || meta.toolName || "",
            extensionName: known.extensionName || meta.extensionName || "",
            status: state
        });
    }

    function _appendTool(tool) {
        const next = root.messages.slice();
        next.push({
            role: "tool",
            text: tool.title,
            toolName: tool.toolName,
            status: tool.status
        });
        root.messages = next;
        root.transcriptChanged();
    }

    // Agent -> client requests. ACP requires the client to answer these or the
    // agent stalls mid-turn, which is the usual cause of a hung panel.
    function _onAgentRequest(obj) {
        switch (obj.method) {
        case "session/request_permission":
            // Auto-approve the first offered option. This mirror is expected
            // to be trusted with the agent's tools; a real approval UI would
            // surface the options and wait for a click instead.
            const options = (obj.params && obj.params.options) || [];
            const chosen = options.length > 0 ? options[0].optionId : null;
            root._respond(obj.id, chosen ? {
                outcome: {
                    outcome: "selected",
                    optionId: chosen
                }
            } : {
                outcome: {
                    outcome: "cancelled"
                }
            });
            break;
        case "fs/read_text_file":
        case "fs/write_text_file":
            // Not advertised in initialize, so goose should not ask; refuse
            // rather than silently mis-handle it if it does.
            root._respondError(obj.id, -32601, "client does not implement " + obj.method);
            break;
        default:
            root._respondError(obj.id, -32601, "method not found: " + obj.method);
            break;
        }
    }

    function _respond(id, result) {
        if (!proc.running)
            return;
        proc.write(JSON.stringify({
            jsonrpc: "2.0",
            id: id,
            result: result
        }) + "\n");
    }

    function _respondError(id, code, message) {
        if (!proc.running)
            return;
        proc.write(JSON.stringify({
            jsonrpc: "2.0",
            id: id,
            error: {
                code: code,
                message: message
            }
        }) + "\n");
    }

    //  Process ─
    Process {
        id: proc

        running: false
        // Required for _send/_notify/_respond above; without it stdin is
        // closed and every write() is a silent no-op.
        stdinEnabled: true
        command: root.command

        stdout: SplitParser {
            // ACP frames messages by newline, and embedded newlines inside
            // text are JSON-escaped, so a line is always one complete message.
            onRead: line => {
                if (!line.trim())
                    return;
                try {
                    root._dispatch(JSON.parse(line));
                } catch (e) {
                    console.warn("Goose ACP: bad frame:", line);
                }
            }
        }

        stderr: SplitParser {
            onRead: line => {
                if (line.trim())
                    console.warn("goose:", line);
            }
        }

        onStarted: root.initialize()

        onExited: code => {
            root.sessionId = "";
            root._pending = ({});
            root._toolCalls = ({});
            root.busy = false;
            if (root.status !== Goose.Error)
                root.status = Goose.Idle;
            // goose is meant to outlive individual turns, so an unexpected exit
            // is surfaced but doesn't auto-restart: the next send() reconnects.
            if (code !== 0)
                console.warn("Goose ACP: goose acp exited with code", code);
        }
    }

    // Drives the two-step handshake forward without threading callbacks
    // through every branch of _dispatch.
    onStatusChanged: {
        if (root.status === Goose.Ready)
            root.flushPending();
    }
}
