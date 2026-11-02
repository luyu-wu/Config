//@ pragma Env QSG_RHI_BACKEND=vulkan
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma UseQApplication
import Quickshell
import "osd"
import "screenshot"
import "notifications"

ShellRoot {
    Wallpaper {
        id: wallpaper
    }

    Corners {}

    Bar {}

    Spotlight {}

    Hyprview {
        wallpaperSource: wallpaper.source
    }

    OsdWindow {}

    NotificationPopups {}

    ScreenshotOverlay {}

    AI {}
}
