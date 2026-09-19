//@ pragma Env QSG_RHI_BACKEND=vulkan
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma UseQApplication
import Quickshell
import "osd"
import "screenshot"
import "notifications"

ShellRoot {
    Corners {}

    Bar {}

    Spotlight {}

    Hyprview {}

    OsdWindow {}

    // Desktop notifications (daemon + toasts), replacing swaync.
    NotificationPopups {}

    // Region screenshot overlay, driven by the global shortcuts declared in
    // Screenshot.qml (quickshell:region, quickshell:regionTemp, quickshell:regionEdit).
    ScreenshotOverlay {}
}
