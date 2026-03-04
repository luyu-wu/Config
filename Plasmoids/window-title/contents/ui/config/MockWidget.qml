import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.iconthemes as KIconThemes
import org.kde.ksvg as KSvg
import org.kde.plasma.plasmoid as Plasmoid
import "../../tools/Tools.js" as Tools

Item {
    id: root
    readonly property int floatingMargins: Kirigami.Units.largeSpacing
    readonly property int panelHeight: 44
    property bool active: true

    height: Math.max(20, Math.max(icon.implicitHeight,txt.implicitHeight))+26
    Layout.fillWidth: true
    KSvg.FrameSvgItem {
        anchors.fill: parent
        anchors.topMargin: -margins.top
        anchors.leftMargin: -margins.left
        anchors.rightMargin: -margins.right
        anchors.bottomMargin: -margins.bottom
        imagePath: "solid/widgets/panel-background"
        prefix: "shadow"
    }
    Item {
        height: root.panelHeight
        anchors.fill: root
        anchors.margins: root.floatingMargins
        clip: true
        KSvg.FrameSvgItem {
            anchors.fill: parent
            imagePath: "widgets/panel-background"
            enabledBorders: "AllBorders"
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin:  Kirigami.Units.largeSpacing
            anchors.rightMargin: Kirigami.Units.largeSpacing
            spacing: 0
            Item{
                Layout.minimumWidth: cfg_firstSpace
                Layout.maximumWidth: cfg_firstSpace
            }
            Item {
                id: icon
                Layout.minimumWidth   : height
                Layout.minimumHeight  : parent.height
                Layout.maximumWidth   : Layout.minimumWidth
                Layout.maximumHeight  : Layout.minimumHeight
                visible               : cfg_visible
                property int thickness: parent.height

                Kirigami.Icon {
                    anchors {
                        fill         : parent
                        topMargin    : thickMargin
                        bottomMargin : thickMargin
                    }
                    source: root.active?"kate":
                        cfg_noIcon?"":
                        cfg_activityIcon?"activities":cfg_customIcon
                    readonly property int thickMargin: cfg_fillThickness ? 0 : (parent.thickness - iconSize) / 2
                    readonly property int iconSize   : cfg_fillThickness ? parent.thickness : Math.min(parent.thickness, cfg_customSize)
                }
            }
            Item{
                Layout.minimumWidth: cfg_midSpace
                Layout.maximumWidth: cfg_midSpace
            }
            PlasmaComponents.Label {
                id: txt
                text                    : active
                ? cfg_txt.replace("%a","Kate").replace("%w","main.qml").replace("%q","Default")
                : cfg_altTxt.replace("%q","ActivityName")
                color                   : Kirigami.Theme.textColor
                verticalAlignment       : Text.AlignVCenter
                elide                   : Tools.getElide(cfg_elidePos)
                width                   : cfg_lengthKind>0?cfg_fixedLength:implicitWidth
                font {
                    capitalization      : cfg_isCaps
                    bold                : cfg_isBold
                    italic              : cfg_isItalic
                    pixelSize           : cfg_fontSize
                }
            }
            Item{
                Layout.minimumWidth: cfg_lastSpace
                Layout.maximumWidth: cfg_lastSpace
            }
            Item{
                Layout.fillWidth: true
            }
            PlasmaComponents.ToolButton {
                id: activeSwitch
                icon.name: "exchange-positions"
                PlasmaComponents.ToolTip{ text: i18n(active?"With active window":"With no active window") }
                onClicked: active = !active
            }
        }
    }
}
