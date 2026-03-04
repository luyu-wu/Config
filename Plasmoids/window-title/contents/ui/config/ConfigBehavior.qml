import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    readonly property alias cfg_filterByScreen: filterByScreenChk.checked
    readonly property alias cfg_filterByMaximized: filterByMaximizedChk.checked
    readonly property alias cfg_showTooltip: showTooltipChk.checked
    readonly property alias cfg_maxminAllowed: maxminAllowed.checked
    readonly property alias cfg_closeAllowed: closeAllowed.checked
    readonly property alias cfg_scrollAllowed: scrollAllowed.checked

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Info Filtering"
        }
        PC3.CheckBox{
            id: filterByScreenChk
            Kirigami.FormData.label: i18n("Show only from current screen:")
        }
        PC3.CheckBox{
            id: filterByMaximizedChk
            Kirigami.FormData.label: i18n("Show only when maximized:")
        }
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Gestures"
        }
        PC3.CheckBox{
            id: showTooltipChk
            Kirigami.FormData.label: i18n("Show tooltip on hover:")
        }
        PC3.CheckBox{
            id: maxminAllowed
            Kirigami.FormData.label: i18n("Double-Click to maximize/minimize:")
        }
        PC3.CheckBox{
            id: closeAllowed
            Kirigami.FormData.label: i18n("Middle-Click to close:")
        }
        PC3.CheckBox{
            id: scrollAllowed
            Kirigami.FormData.label: i18n("Scroll through tasks:")
        }
    }
}
