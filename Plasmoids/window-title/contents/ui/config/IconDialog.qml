import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.iconthemes as KIconThemes
import org.kde.ksvg as KSvg

RowLayout {
    property alias value: placeHolderIcon.source
    Button {
        implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
        implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
        onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()
        KIconThemes.IconDialog {
            id: iconDialog
            onIconNameChanged: value = iconName
        }
        KSvg.FrameSvgItem {
            id: previewFrame
            anchors.centerIn: parent
            imagePath: "widgets/panel-background"
            width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
            height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom
            Kirigami.Icon {
                id: placeHolderIcon
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: width
                source: "kde-symbolic"
            }
        }

        Menu {
            id:iconMenu
            y: parent.height
            MenuItem {
                text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                icon.name: "document-open-folder"
                Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
                onClicked: iconDialog.open()
            }
            MenuItem {
                text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
                icon.name: "kt-restore-defaults"
                onClicked: value = Tools.defaultIconName
            }
        }
    }
    PlasmaComponents.Label{
        text:`"${value}"`
    }
}
