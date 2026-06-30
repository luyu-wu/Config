

-----------------------------
---- ENVIRONMENT VARIABLES --
-----------------------------

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("SAL_USE_VCLPLUGIN","qt6")
hl.env("TERMINAL", "foot")
hl.env("XDG_MENU_PREFIX", "plasma-")
hl.env("HYPRCURSOR_THEME", "macOS")
hl.env("HYPRCURSOR_SIZE", "32")

-- Chinese input (uncomment to enable)
-- hl.env("LANGUAGE", "zh_CN:en_US")
-- hl.env("LANG",     "zh_CN.UTF-8")
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("QT_LOGGING_RULES", "*.debug=false")

-----------------------------
-------- AUTOSTART ----------
-----------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start plasma-polkit-agent")

    hl.exec_cmd("fcitx5")
    hl.exec_cmd("swaync")
    -- hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("cairo-dock -o")
    hl.exec_cmd("qs")
    -- hl.exec_cmd("bluetooth off")
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("quickshell -p ~/.config/hypr/Scripts/qs-hyprview/")
    hl.exec_cmd("quickshell -p ~/.config/hypr/Scripts/qs-round/")
    hl.exec_cmd("play /home/chrysanthemum/.config/hypr/Assets/startup.mp3")
    hl.exec_cmd("snappy-switcher --daemon")
    hl.exec_cmd("gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'")
    -- hl.exec_cmd("hyprctl plugin load /home/chrysanthemum/Code/Config/hypr/Shaders/hyprselect.so")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
end)
