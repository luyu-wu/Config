-- Keybindings
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local SUPER       = "SUPER"
local SUPER_SHIFT = "SUPER + SHIFT"


-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd brightnessUp"),
    { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd brightnessDown"),
    { repeating = true, locked = true })
hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd brightnessUpFine"),
    { repeating = true, locked = true })
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd brightnessDownFine"),
    { repeating = true, locked = true })

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd volumeUp"),
    { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd volumeDown"),
    { repeating = true, locked = true })
hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd volumeUpFine"),
    { repeating = true, locked = true })
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd volumeDownFine"),
    { repeating = true, locked = true })

-- Mute / Power / Media
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd volumeMute"), { locked = true })
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("pkill wleave || wleave -m 500 -c 50 -f"), { locked = true })
hl.bind("SHIFT + XF86PowerOff", hl.dsp.exec_cmd("systemctl suspend"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioMedia", hl.dsp.exec_cmd("~/.config/hypr/Scripts/powermode.sh"))

local MAX_ZOOM = 10
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5
local function zoom(offset)
    local current = hl.get_config("cursor.zoom_factor")
    if offset ~= nil then
        current = current + offset
    elseif current ~= MIN_ZOOM then
        current = MIN_ZOOM
    else
        current = ZOOM_TOGGLE_FACTOR
    end
    current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
    hl.config({ cursor = { zoom_factor = current } })
end

hl.bind("SUPER + mouse_down", function()
    zoom(-0.5)
end)
hl.bind("SUPER + mouse_up", function()
    zoom(0.5)
end)

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace",disable_inhibit=true})
-- Line format: "<active> <travel>"
local EXPOSE_PROG = "/dev/shm/qs-expose"
local EXPOSE_SCALE = 400
local exposeFile = io.open(EXPOSE_PROG, "w")

local exposeVelocity, exposeLastTime = 0, nil
local exposeTravel = 0

local function publish_expose(active, value)
	if not exposeFile then
		return
	end
	exposeFile:seek("set", 0)
	exposeFile:write(string.format("%d %.4f\n", active and 1 or 0, value))
	exposeFile:flush()
end

publish_expose(false, 0)

hl.gesture({
	fingers = 3,
	direction = "vertical",
	disable_inhibit = true,
	action = {
		start = function(e)
			exposeTravel = 0
			exposeVelocity = 0
			exposeLastTime = e and e.time_ms or nil
			publish_expose(true, 0)
		end,
		update = function(e)
			local delta = (e and e.delta and e.delta.y) or 0
			local now = e and e.time_ms
			if now and exposeLastTime then
				local dt = (now - exposeLastTime) / 1000
				if dt > 0.001 then
					local instant = -delta / (EXPOSE_SCALE * dt)
					exposeVelocity = exposeVelocity + 0.35 * (instant - exposeVelocity)
				end
			end
			exposeLastTime = now

			exposeTravel = exposeTravel - delta / EXPOSE_SCALE
			publish_expose(true, exposeTravel)
		end,
		finish = function()
			publish_expose(false, exposeVelocity)
		end,
	},
})

hl.gesture({ fingers = 3, direction = "pinchin", action = "cursorZoom", zoom_level = 1, scale=1, mode = "live" })
hl.gesture({ fingers = 3, direction = "pinchout", action = "cursorZoom"})


hl.gesture({fingers=4, direction="right",action=function() hl.exec_cmd("playerctl previous") end})
hl.gesture({fingers=4, direction="left",action=function() hl.exec_cmd("playerctl next") end})

local volume_gesture = function(change)
	hl.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. math.abs(change) .. "%" .. (change<0 and "-" or "+"))
	hl.exec_cmd("quickshell ipc -p ~/.config/quickshell call osd volumeRefresh")
end
hl.gesture({
  fingers = 4,
  direction = "vertical",
  action = {
    start = function(e) volume_gesture(-0.1*e.delta.y) end,
    update = function(e) volume_gesture(-0.1*e.delta.y) end
  },
  disable_inhibit = true
})

hl.bind(SUPER_SHIFT .. " + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(SUPER .. " + A", hl.dsp.exec_cmd("scrcpy -w -S -K"))
hl.bind(SUPER_SHIFT .. " + S", hl.dsp.global("quickshell:region"))
hl.bind("Print", hl.dsp.global("quickshell:regionTemp"), { locked = true })


-- Pass F2 to OBS (push-to-talk / global shortcut)
hl.bind("SHIFT + F2", hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }), { non_consuming = true })

-- Expose / overview
hl.bind(SUPER .. " + Tab",hl.dsp.exec_cmd("quickshell ipc -p ~/.config/quickshell/ call expose toggle"))

hl.bind(SUPER .. " + R", hl.dsp.global('quickshell:Spotlight'))
hl.bind(SUPER_SHIFT .. " + A", hl.dsp.global('quickshell:Intelligence'))

-- Night mode
hl.bind(SUPER .. " + M", hl.dsp.exec_cmd("pkill hyprsunset || hyprsunset -t 4000"))
hl.bind(SUPER_SHIFT .. " + M", hl.dsp.exec_cmd("pkill hyprsunset || hyprsunset -t 3000"))

-- Apps
hl.bind(SUPER .. " + W", hl.dsp.exec_cmd("firefox"))
hl.bind(SUPER_SHIFT .. " + W", hl.dsp.exec_cmd("firefox", { float = true }))
hl.bind(SUPER .. " + O", hl.dsp.exec_cmd("osu-lazer"))
hl.bind(SUPER .. " + I", hl.dsp.exec_cmd("systemsettings"))
-- hl.bind(SUPER_SHIFT .. " + I", hl.dsp.exec_cmd("invertactivewindow"))
hl.bind(SUPER .. " + P", hl.dsp.exec_cmd("foot -e micro ~/Code/Config/hypr/monitors.lua", { float = true }))
hl.bind(SUPER .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(SUPER .. " + T", hl.dsp.exec_cmd("foot"))
hl.bind("CTRL + SHIFT + escape", hl.dsp.exec_cmd("foot -e btop", { float = true }))
hl.bind(SUPER_SHIFT .. " + T", hl.dsp.exec_cmd("foot", { float = true }))
hl.bind(SUPER_SHIFT .. " + L", hl.dsp.exec_cmd("hyprlock"))

--[[
hl.bind(SUPER_SHIFT .. " + L",function()
  hl.timer(function()
    hl.dispatch(hl.dsp.dpms({ action = "disable" }))
  end, {timeout = 1000, type = "oneshot"})
end)
--]]
-----------------------------
---- SPECIAL WORKSPACES  ----
-----------------------------

hl.bind(SUPER .. " + D", hl.dsp.workspace.toggle_special("discord"))
hl.bind(SUPER_SHIFT .. " + D", hl.dsp.window.move({ workspace = "special:discord" }))
hl.bind(SUPER .. " + S", hl.dsp.exec_cmd("fooyin"))

hl.bind(SUPER .. " + C", hl.dsp.workspace.toggle_special("code"))
hl.bind(SUPER .. " + X", hl.dsp.workspace.toggle_special("obs"))
hl.bind(SUPER .. " + N", hl.dsp.workspace.toggle_special("note"))
hl.bind(SUPER .. " + G", hl.dsp.workspace.toggle_special("game"))
hl.bind(SUPER_SHIFT .. " + G", hl.dsp.window.move({ workspace = "special:game" }))
hl.bind(SUPER_SHIFT .. " + X", hl.dsp.workspace.toggle_special("windows"),{bypass=true,submap_universal=true})
hl.gesture({ fingers = 4, direction = "down", mods = "SUPER", action = "special", workspace_name = "windows", disable_inhibit = true })

-----------------------------
--------  RELOAD  -----------
-----------------------------

hl.bind("CTRL + SHIFT + delete", function()
    hl.dispatch(hl.dsp.exec_cmd("hyprctl reload"))
    hl.dispatch(hl.dsp.exec_cmd("pkill wofi"))
end)

-----------------------------
-----  WINDOW MANAGEMENT  ---
-----------------------------

hl.bind(SUPER .. " + Q", hl.dsp.window.close())
hl.bind(SUPER .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(SUPER .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen"}))
hl.bind(SUPER_SHIFT .. " + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 3 , action = "toggle"}))
hl.bind(SUPER .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(SUPER_SHIFT .. " + P", hl.dsp.window.pin())

-- Focus
hl.bind(SUPER .. " + up", function()
    hl.dispatch(hl.dsp.focus({ direction = "u" }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind(SUPER .. " + down", function()
    hl.dispatch(hl.dsp.focus({ direction = "d" }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind(SUPER .. " + right", function()
    hl.dispatch(hl.dsp.focus({ direction = "r" }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind(SUPER .. " + left", function()
    hl.dispatch(hl.dsp.focus({ direction = "l" }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- Workspace navigation
local function ws_rel(dir)
    local cur = hl.get_active_workspace()
    for _, ws in ipairs(hl.get_workspaces()) do
        if not ws.special and ws.monitor and ws.monitor.id == cur.monitor.id
            and ws.windows > 0 and (ws.id - cur.id) * dir > 0 then
            return "m" .. (dir > 0 and "+1" or "-1")
        end
    end
    return dir > 0 and "+1" or "-1"
end

hl.bind(SUPER .. " + 1", function()
    hl.dispatch(hl.dsp.focus({ workspace = ws_rel(-1), on_current_monitor = true }))
end)
hl.bind(SUPER .. " + 2", function()
    hl.dispatch(hl.dsp.focus({ workspace = ws_rel(1), on_current_monitor = true }))
end)
hl.bind(SUPER_SHIFT .. " + 1", function()
    hl.dispatch(hl.dsp.window.move({ workspace = ws_rel(-1) }))
end)
hl.bind(SUPER_SHIFT .. " + 2", function()
    hl.dispatch(hl.dsp.window.move({ workspace = ws_rel(1) }))
end)

-- Move window to empty workspace with SUPER+SHIFT+RMB
hl.bind(SUPER_SHIFT .. " + mouse:273", hl.dsp.focus({ workspace = "emptynm"}))

-- Move / resize with mouse
hl.bind(SUPER .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(SUPER .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
