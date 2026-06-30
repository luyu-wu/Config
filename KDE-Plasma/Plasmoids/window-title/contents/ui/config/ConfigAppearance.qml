import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.iconthemes as KIconThemes
import org.kde.ksvg as KSvg

import "../../tools/Tools.js" as Tools

Kirigami.ScrollablePage {
    id: root
    readonly property alias cfg_firstSpace: firstSpace.value
    readonly property alias cfg_midSpace: midSpace.value
    readonly property alias cfg_lastSpace: lastSpace.value
    readonly property alias cfg_txt: txt.text
    readonly property alias cfg_altTxt: altTxt.text
    readonly property alias cfg_isBold: boldChk.checked
    readonly property alias cfg_isItalic: italicChk.checked
    readonly property alias cfg_isCaps: capsChk.checked
    readonly property alias cfg_fontSize: fontSize.value
    readonly property alias cfg_visible: iconChk.checked
    readonly property alias cfg_lengthKind: lengthKind.currentIndex
    readonly property alias cfg_fixedLength: fixedLength.value
    readonly property alias cfg_fillThickness: fillThickness.checked
    readonly property alias cfg_noIcon: noIcon.checked
    readonly property alias cfg_activityIcon: activityIcon.checked
    readonly property alias cfg_customIcon: iconDialog.value
    readonly property alias cfg_txtSameFound: txtSameFound.text
    readonly property alias cfg_customSize: customSize.value
    readonly property alias cfg_elidePos: elidePos.currentIndex

    header : MockWidget{}
    Kirigami.FormLayout {
        Layout.fillWidth: true
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Text"
        }
        RowLayout {
            Kirigami.FormData.label: i18n("When title available:")
            PC3.TextField { id: txt }
            PC3.ToolButton {
                icon.name: "documentinfo"
                PC3.ToolTip{ text: i18n("This pattern will be shown when a window is active.<p>
                    <b><i>Substitutions:</i></b><p>
                    %a - Application Name<p>
                    %w - Window Title<p>
                    %q - Activity Info<p>
                    Use HTML tags for bold, italic and multi-line text") }
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("When Application Name and Window Title are same:")
            PC3.TextField { id: txtSameFound }
            PC3.ToolButton {
                icon.name: "documentinfo"
                PC3.ToolTip{ text: i18n("To prevent results like:<p>Neovide - Neovide") }
            }
        }
        RowLayout{
            Kirigami.FormData.label: i18n("When title unavailable:")
            PC3.TextField {
                id: altTxt
                text: "%q"
            }
            PC3.ToolButton {
                icon.name: "documentinfo"
                PC3.ToolTip{ text: i18n("This pattern will be shown when no window is active.<p>
                    <b>Substitutions:</b><p>
                    %q - Activity Info<p>
                    Use HTML tags for bold, italic and multi-line text") }
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Text Formatting:")
            PC3.SpinBox{
                id: fontSize
                from: 8
                to: 64
            }
            PC3.ToolButton{
                id: boldChk
                checkable: true
                icon.name: "format-text-bold"
                display: AbstractButton.IconOnly
                text: i18n("Bold")
                height: Kirigami.Units.smallSpacing
                PC3.ToolTip{ text: i18n("<b>Bold</b>") }
            }
            PC3.ToolButton{
                id: italicChk
                checkable: true
                display: AbstractButton.IconOnly
                text: i18n("Italic")
                icon.name: "format-text-italic"
                height: Kirigami.Units.smallSpacing
                PC3.ToolTip{ text: i18n("<i>Italic</i>") }
            }
            PC3.ToolButton{
                id: capsChk
                checkable: true
                icon.name: "format-text-capitalize"
                text: i18n("Capitalize")
                display: AbstractButton.IconOnly
                height: Kirigami.Units.smallSpacing
                PC3.ToolTip{ text: i18n("<b>C</b>apitalize <b>F</b>irst <b>L</b>etters") }
            }
        }
        PC3.ComboBox {
            id: elidePos
            Kirigami.FormData.label: i18n("Elide Position:")
            model: ["None","Left","Middle","Right"]
            visible: lengthKind.currentIndex > 0
        }
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Icon"
        }
        PC3.CheckBox {
            id: iconChk
            Kirigami.FormData.label: i18n("Visible:")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Size:")
            RadioButton{
                id: customThickness
                text: i18n("Custom Size")
                icon.name:"image-resize-symbolic"
                checked: !fillThickness.checked
            }
            RadioButton{
                id: fillThickness
                text: i18n("Fill Thickness")
                icon.name: "panel-fit-height"
            }
        }
        PC3.SpinBox{
            id: customSize
            from: 8
            to: 50
            enabled: customThickness.checked
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Placeholder icon:")
            RadioButton{
                id: customIcon
                text: i18n("Custom Icon")
                icon.name:"dialog-icon-preview"
                checked: !activityIcon.checked && !noIcon.checked
            }
            RadioButton{
                id: activityIcon
                text: i18n("Activity Icon")
                icon.name: "activities"
            }
            RadioButton{
                id: noIcon
                text: i18n("Preserve Space")
                icon.name: "edit-none"
            }
        }
        IconDialog{
            id: iconDialog
            visible: customIcon.checked
        }
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Margins"
        }
        PC3.ComboBox {
            id:lengthKind
            Kirigami.FormData.label: i18n("Length:")
            model: ["Based on contents","Fixed Length","Maximum Length"]
        }
        RowLayout{
            Kirigami.FormData.label: i18n("Custom length:")
            visible: lengthKind.currentIndex > 0
            PC3.Slider{
                id:fixedLength
                from: 24
                to: 1500
                stepSize:1
            }
            PC3.Label{
                text: fixedLength.value+" px."
            }
        }

        PC3.SpinBox {
            id: firstSpace
            Kirigami.FormData.label: i18n("Space before icon:")
            from: 0
            to: 999
        }
        PC3.SpinBox {
            id: midSpace
            Kirigami.FormData.label: i18n("Space between icon and text:")
            from: 0
            to: 999
        }
        PC3.SpinBox {
            id: lastSpace
            Kirigami.FormData.label: i18n("Space after text:")
            from: 0
            to: 999
        }
    }
}
