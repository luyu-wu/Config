local darkMode = _G.darkMode

local bar_bg_breeze_unf = "rgb(eff0f1)"
local bar_bg_teams = "rgb(ebebeb)"
local bar_bg_chromium = "rgb(dee5d8)"
local bar_bg_chromium_unf = "rgb(e2e3dd)"

if darkMode then
	bar_bg_breeze_unf = "rgb(212429)"
	bar_bg_teams = "rgb(0A0A0A)"
	bar_bg_chromium_unf = "rgb(282C26)"
	bar_bg_chromium =  "rgb(1B211A)"
end

-----------------------------
------  LAYER RULES  --------
-----------------------------

hl.layer_rule({
    name    = "No Anims",
    match   = { namespace = "hyprpicker|selection|hyprpaper|qs:screencorners|qs:screenshot|qs:expose"},
    no_anim = true,
    blur    = false,
})

hl.layer_rule({
    name         = "Enable Blur",
    match        = { namespace = "wofi|krunner|notifications|qs:spotlight|qs:ai|qs:screenshot" },
    blur         = true,
})

hl.layer_rule({
	name         = "AI Slide",
	match        = { namespace = "qs:ai" },
	animation = "slide"

})

hl.layer_rule({
    name         = "Cairo",
    match        = { namespace = "cairo-dock-_MainDock_" },
    blur         = true,
})

hl.layer_rule({
    name         = "Quickshell Notifications",
    match        = { namespace = "qs:notifications" },
    blur         = true,
    blur_popups  = true,
    no_anim      = true,
})


hl.layer_rule({
    name         = "Quickshell Popups",
    match        = { namespace = "qs:popup|quickshell|qs:osd" },
    no_anim      = false,
    blur         = true,
    blur_popups  = true,
})


-----------------------------
------  WINDOW RULES  -------
-----------------------------

hl.window_rule({
    name           = "All Windows",
    match          = { class = "negative:"},
    suppress_event = "maximize",
    no_blur        = true,
})

hl.window_rule({
    name  = "Float Windows",
    match = { class = "xdg-desktop-portal-gtk|io.bassi.Amberol|python3|org.gnome.Loupe|com.github.huluti.Curtail|dev.bragefuglseth.Fretboard|eww|com.github.GradienceTeam.Gradience|pavucontrol|blueman-manager|nm-connection-editor|blueberry.py|Color Picker|Network|xdg-desktop-portal|xdg-desktop-portal-hyprland|xdg-desktop-portal-gnome|io.github.nate_xyz.Chromatic|it.mijorus.whisper|io.github.giantpinkrobots.flatsweep|VirtualBox Machine|org.gnome.Nautilus|floatterm|moe.launcher.an-anime-game-launcher|org.gnome.clocks|org.gnome.Calculator|io.github.kaii_lb.Overskride|org.matplotlib.Matplotlib3|org.gnome.Decibels|org.kde.dolphin|org.kde.gwenviewsudo|io.github.nokse22.trivia-quiz|com.saivert.pwvucontrol|io.missioncenter.MissionCenter|org.kde.plasmashell|pavucontrol-qt|hu.irl.cameractrls|org.freedesktop.impl.portal.desktop.kde|mpv|org.fooyin.fooyin|zoom" },
    float = true,
})

hl.window_rule({
    name  = "File Manager Size",
    match = { class = "org.gnome.Nautilus|org.kde.dolphin" },
    size  = "(monitor_w*0.4) (monitor_h*0.4)",
})

hl.window_rule({
    name         = "Popups",
    match        = { title = "Save Image|New Layer|Rotate View|polkit-gnome-authentication-agent-1" },
    stay_focused = true,
})

hl.window_rule({
    name  = "KCM Controls",
    match = { class = "(kcm)(.*)|pavucontrol-qt" },
    float = true,
})

hl.window_rule({
    name  = "Firefox PiP",
    match = { title = "Picture-in-Picture" },
    float = true,
    size  = "(monitor_w*0.25) (monitor_h*0.25)",
    move  = "(monitor_w*0.743) (monitor_h*0.035)",
    pin   = true,
})

hl.window_rule({
    name            = "Faster Touchpad",
    match           = { class = "dev.zed.Zed|org.gnome.Papers|wechat|com.github.flxzt.rnote" },
    scroll_touchpad = 0.3,
})
hl.window_rule({
    name            = "Even Faster Touchpad",
    match           = { class = "ai.storyteller.wordcraft|ai.storyteller.pdfcraft" },
    scroll_touchpad = 1,
})



hl.window_rule({
    name            = "Slower Touchpad",
    match           = { class = "thorium-browser|chromium|google-chrome|vesktop|spotify" },
    scroll_touchpad = 0.06,
})

hl.window_rule({
    name                     = "Foot Terminal",
    match                    = { class = "foot" },
    scroll_touchpad          = 0.5,
    ["hyprbars:bar_color"]   = "rgb(333333)",
    ["hyprbars:title_color"] = "rgb(E0E0E0)",
    border_color             = "rgb(707070) rgb(505050)",
    move                     = "(cursor_x-window_w*0.5) (cursor_y-window_h*0.2)",
})

hl.window_rule({
    name                   = "Fusion",
    match                  = { class = "fusion360.exe" },
    ["hyprbars:bar_color"] = "rgb(d9d9d9)",
})

hl.window_rule({
    name                   = "Thorium Unfocused",
    match                  = { class = "thorium-browser|chromium|google-chrome", focus = false },
    ["hyprbars:bar_color"] = bar_bg_chromium_unf,

})

hl.window_rule({
    name                   = "Thorium",
    match                  = { class = "thorium-browser|chromium|google-chrome", focus = true },
    ["hyprbars:bar_color"] = bar_bg_chromium,

})

hl.window_rule({
    name                     = "Libadwaita",
    match                    = { class = "com.github.flxzt.rnote|io.github.vani_tty1.memerist", focus = true },
    ["hyprbars:bar_color"]   = "rgb(ffffff)",
    ["hyprbars:title_color"] = "rgb(ffffff)",
})

hl.window_rule({
    name                     = "Libadwaita-Unfocus",
    match                    = { class = "com.github.flxzt.rnote|io.github.vani_tty1.memerist", focus = false },
    ["hyprbars:bar_color"]   = "rgb(fafafb)",
    ["hyprbars:title_color"] = "rgb(fafafa)",
})

hl.window_rule({
    name                     = "Breeze Dark",
    match                    = { class = "org.kde.kdenlive|org.kde.krita", focus = true },
    ["hyprbars:bar_color"]   = "rgb(292d31)",
    ["hyprbars:title_color"] = "rgb(E0E0E0)",
})

hl.window_rule({
    name                     = "Breeze Dark-Unfocus",
    match                    = { class = "org.kde.kdenlive|org.kde.krita", focus = false },
    ["hyprbars:bar_color"]   = "rgb(212429)",
    ["hyprbars:title_color"] = "rgb(A0A0A0)",
})

hl.window_rule({
    name                   = "Teams",
    match                  = { class = "teams-for-linux" },
    ["hyprbars:bar_color"] = bar_bg_teams

})

hl.window_rule({
    name                     = "OBS",
    match                    = { class = "com.obsproject.Studio" },
    ["hyprbars:bar_color"]   = "rgb(212121)",
    ["hyprbars:title_color"] = "rgb(E0E0E0)",
})

hl.window_rule({
    name                     = "GIMP",
    match                    = { class = "gimp" },
    ["hyprbars:bar_color"]   = "rgb(3c3c3c)",
    ["hyprbars:title_color"] = "rgb(E0E0E0)",
})

hl.window_rule({
    name                     = "Wordcraft",
    match                    = { class = "ai.storyteller.wordcraft" },
    ["hyprbars:bar_color"]   = "rgb(f0f0f0)",
})


hl.window_rule({
    name  = "Spotify",
    match = { class = "Spotify|spotify" },
    ["hyprbars:bar_color"]   = "rgb(000000)",
    ["hyprbars:title_color"] = "rgb(E0E0E0)",
})

hl.window_rule({
    name  = "Photocraft",
    match = { class = "ai.storyteller.photocraft" },
    ["hyprbars:bar_color"]   = "rgb(535353)",
    ["hyprbars:title_color"] = "rgb(E0E0E0)",
})

hl.window_rule({
    name     = "WeChat",
    match    = { class = "wechat" },
    decorate = true,
   	["hyprbars:no_bar"] = true

})
hl.window_rule({
	name="WeChat Popups",
	match={title="wechat"},
	no_anim  = true,
	decorate = false,
	["hyprbars:no_bar"] = true


})

hl.window_rule({
    name              = "scrcpy",
    match             = { class = "scrcpy" },
    --size              = "509 1181",
    keep_aspect_ratio = true,
    float             = true,
    --hyprbars          = { no_bar = true },
})


hl.window_rule({
    -- Default --hyprbars style for unfocused windows not covered by a more specific rule
    name                     = "Unfocused Bar Color",
    match                    = { class = "negative:vesktop|foot|floatterm|fusion360.exe|thorium-browser|dev.zed.Zed|spotify||teams-for-linux|com.obsproject.Studio|org.kde.kdenlive|gimp|google-chrome|chromium|zoom|Spotify|org.kde.krita|ai.storyteller.wordcraft|ai.storyteller.photocraft", focus = false },

    ["hyprbars:bar_color"]   = bar_bg_breeze_unf,
    ["hyprbars:title_color"] = "rgb(808080)",
})

hl.window_rule({
	name = "CSD Windows",
	match = {class="com.github.flxzt.rnote|io.github.vani_tty1.memerist|org.gnome.World.PikaBackup|org.pipewire.Helvum|io.missioncenter.MissionCenter|dev.deedles.Trayscale|org.gnome.gitg|xyz.tytanium.DoorKnocker|localsend|de.haeckerfelix.Fragments|ONLYOFFICE|org.gnome.Meld|moe.launcher.the-honkers-railway-launcher"},
	["hyprbars:no_bar"] = true
})

hl.window_rule({
    name  = "Pinned",
    match = { pin = true },
    ["hyprbars:no_bar"] = true
})

hl.window_rule({
    name                = "Fake Fullscreen",
    match               = { fullscreen_state_client = 2 },
    ["hyprbars:no_bar"] = true
})

hl.window_rule({
    name       = "Fullscreen",
    match      = { class = "osu!|dev.zed.Zed|SiYuan|virt-viewer" },
    fullscreen = true,
})

hl.window_rule({
    name              = "Fooyin Size",
    match             = { class = "org.fooyin.fooyin" },
    size              = "708 645",
    keep_aspect_ratio = true,
})


-----------------------------
--- SPECIAL WORKSPACE RULES -
-----------------------------

hl.window_rule({
    name                     = "Zed",
    match                    = { class = "dev.zed.Zed",focus=true},
    workspace                = "special:code",
    ["hyprbars:bar_color"]   = "rgb(323232)",
    ["hyprbars:title_color"] = "rgb(F0F0F0)",
})
hl.window_rule({
    name                     = "Zed Unfocused",
    match                    = { class = "dev.zed.Zed" ,focus=false},
    workspace                = "special:code",
    ["hyprbars:bar_color"]   = "rgb(222221)",
    ["hyprbars:title_color"] = "rgb(F0F0F0)",
})


hl.window_rule({
    name                     = "Discord",
    match                    = { class = "vesktop" },
    workspace                = "special:discord",
    ["hyprbars:bar_color"]   = "rgb(121214)",
    ["hyprbars:title_color"] = "rgb(E0E0E0)",
})

hl.window_rule({
    name      = "Games",
    match     = { class = "genshinimpact.exe|osu!|moe.launcher.an-anime-game-launcher|osgViewer|org.vinegarhq.Sober|(Minecraft)(.*)" },
    workspace = "special:game",
})

hl.window_rule({
    name      = "VM Windows",
    match     = { class = "virt-viewer|com.moonlight_stream.Moonlight" },
    workspace = "special:windows",
})

hl.window_rule({
    name      = "OBS Workspace",
    match     = { class = "com.obsproject.Studio" },
    workspace = "special:obs",
})


-----------------------------
----- WORKSPACE RULES -------
-----------------------------

-- Default layout for regular workspaces
hl.workspace_rule({ workspace = "", layout = "dwindle" })

-- Special workspace on-created-empty commands
hl.workspace_rule({ workspace = "special:code", on_created_empty = "zeditor" })
hl.workspace_rule({
    workspace = "special:discord",
    on_created_empty =
    "vesktop --enable-ozone-platform=wayland --enable-wayland-ime"
})
hl.workspace_rule({ workspace = "special:obs", on_created_empty = "obs" })
hl.workspace_rule({ workspace = "special:windows", on_created_empty = 'moonlight stream Chrysanthemum "Desktop"' })
