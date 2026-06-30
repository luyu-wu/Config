import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.taskmanager       as TaskManager
import org.kde.kirigami          as Kirigami
import org.kde.activities        as Activities
import "../tools/Tools.js"       as Tools

PlasmoidItem {
    id: root
    clip: true
    Plasmoid.constraintHints:   Plasmoid.CanFillArea
    preferredRepresentation:    fullRepresentation

    readonly property bool isVertical:              plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool existsWindowActive:      windowInfoLoader.item && windowInfoLoader.item.existsWindowActive
    readonly property bool isActiveWindowPinned:    existsWindowActive && activeTaskItem.isOnAllDesktops
    readonly property bool isActiveWindowMaximized: existsWindowActive && activeTaskItem.isMaximized
    readonly property var cfg:                      plasmoid.configuration

    property Item activeTaskItem:                   windowInfoLoader.item.activeTaskItem
    property var icon:                              Tools.getIcon()
    property string text:                           Tools.getText()

    states: [
        State{
            name: "editMode"
            when:  Plasmoid.containment.corona?.editMode?true:false
            PropertyChanges{
                target: root
                text:   "Edit Mode"
                icon:   "document-edit"
                Layout.minimumWidth: isVertical?parent.width:titleLayout.implicitWidth
                Layout.maximumWidth: Layout.minimumWidth
                Layout.minimumHeight: isVertical?titleLayout.implicitHeight:parent.height
                Layout.maximumHeight: Layout.minimumHeight
            }
        },
        State{
            name: "contentsLength"
            when: cfg.lengthKind === 0 && !isVertical
            PropertyChanges{
                target: root
                Layout.minimumWidth: titleLayout.implicitWidth
                Layout.maximumWidth: Layout.minimumWidth
                Layout.fillHeight:   true
            }
        },
        State{
            name: "fixedLength"
            when: cfg.lengthKind === 1 && !isVertical
            PropertyChanges{
                target: root
                Layout.minimumWidth: cfg.fixedLength
                Layout.maximumWidth: cfg.fixedLength
                Layout.fillHeight:   true
            }
        },
        State{
            name: "maximumLength"
            when: cfg.lengthKind === 2 && !isVertical
            PropertyChanges{
                target: root
                Layout.minimumWidth: Math.min(cfg.fixedLength,titleLayout.implicitWidth)
                Layout.maximumWidth: Math.min(cfg.fixedLength,titleLayout.implicitWidth)
                Layout.fillHeight:   true
            }
        },
        State{
            name: "contentsLengthVert"
            when: cfg.lengthKind === 0 && isVertical
            PropertyChanges{
                target: root
                Layout.minimumHeight: titleLayout.implicitHeight
                Layout.maximumHeight: Layout.minimumHeight
                Layout.fillWidth:     true
            }
        },
        State{
            name: "fixedLengthVert"
            when: cfg.lengthKind === 1 && isVertical
            PropertyChanges{
                target: root
                Layout.minimumHeight: cfg.fixedLength
                Layout.maximumHeight: cfg.fixedLength
                Layout.fillWidth:     true
            }
        },
        State{
            name: "maximumLengthVert"
            when: cfg.lengthKind === 2 && isVertical
            PropertyChanges{
                target: root
                Layout.minimumHeight: Math.min(cfg.fixedLength,titleLayout.implicitHeight)
                Layout.maximumHeight: Math.min(cfg.fixedLength,titleLayout.implicitHeight)
                Layout.fillWidth:     true
            }
        }
    ]

    TaskManager.ActivityInfo { id: activityInfo }
    Activities.ActivityInfo { id: fullActivityInfo; activityId: ":current" }
    TaskManager.VirtualDesktopInfo { id: virtualDesktopInfo }
    Loader {
        id: windowInfoLoader
        sourceComponent: plasmaTasksModel
        Component{
            id: plasmaTasksModel
            PlasmaTasksModel{}
        }
    }
    Title { id: titleLayout }
    ActionsMouseArea{}
    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        active: text !== ""
        interactive: true
        location: plasmoid.location
        visible: cfg.showTooltip
        mainItem: RowLayout {
            spacing:                    Kirigami.Units.largeSpacing
            Layout.margins:             Kirigami.Units.smallSpacing
            Kirigami.Icon {
                source: root.icon
            }
            PlasmaComponents.Label {
                id: fullText
                elide:Text.ElideRight
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                text:root.text
            }
        }
    }

    // ─── Window Actions Menu ────────────────────────────────────────────────────
    // Using PlasmaExtras.Menu with visualParent so it anchors correctly
    // relative to the panel edge (above/below/left/right depending on location).
    PlasmaExtras.Menu {
        id: windowMenu
        visualParent: fullRepresentationItem   // anchor to the widget itself
        placement: {
            switch (plasmoid.location) {
                case PlasmaCore.Types.TopEdge:    return PlasmaExtras.Menu.BottomPosedLeftAlignedPopup
                case PlasmaCore.Types.LeftEdge:   return PlasmaExtras.Menu.RightPosedTopAlignedPopup
                case PlasmaCore.Types.RightEdge:  return PlasmaExtras.Menu.LeftPosedTopAlignedPopup
                default:                          return PlasmaExtras.Menu.TopPosedLeftAlignedPopup
            }
        }

        PlasmaExtras.MenuItem {
            text: root.existsWindowActive
                  ? i18n("About %1", root.text)
                  : i18n("About This App")
            enabled: root.existsWindowActive
            onClicked: {
                if (root.activeTaskItem)
                    root.activeTaskItem.actionAbout()
            }
        }

        //PlasmaExtras.MenuSeparator {}

        PlasmaExtras.MenuItem {
            text: i18n("Preferences…")
            enabled: root.existsWindowActive
            onClicked: {
                if (root.activeTaskItem)
                    root.activeTaskItem.actionSettings()
            }
        }

        //PlasmaExtras.MenuSeparator {}

        PlasmaExtras.MenuItem {
            text: root.isActiveWindowMaximized ? i18n("Restore") : i18n("Maximize")
            enabled: root.existsWindowActive
            onClicked: {
                if (root.activeTaskItem)
                    root.activeTaskItem.actionMaximize()
            }
        }

        PlasmaExtras.MenuItem {
            text: i18n("Minimize")
            enabled: root.existsWindowActive
            onClicked: {
                if (root.activeTaskItem)
                    root.activeTaskItem.actionMinimize()
            }
        }

        PlasmaExtras.MenuItem {
            text: i18n("Move to Front")
            enabled: root.existsWindowActive
            onClicked: {
                if (root.activeTaskItem)
                    root.activeTaskItem.actionRaise()
            }
        }

        PlasmaExtras.MenuItem {
            text: i18n("Send to Back")
            enabled: root.existsWindowActive
            onClicked: {
                if (root.activeTaskItem)
                    root.activeTaskItem.actionLower()
            }
        }

        //PlasmaExtras.MenuSeparator {}

        PlasmaExtras.MenuItem {
            text: i18n("Close Window")
            enabled: root.existsWindowActive
            onClicked: {
                if (root.activeTaskItem)
                    root.activeTaskItem.actionClose()
            }
        }

        PlasmaExtras.MenuItem {
            text: root.existsWindowActive
                  ? i18n("Quit %1", root.text)
                  : i18n("Quit Application")
            enabled: root.existsWindowActive
            onClicked: {
                if (root.activeTaskItem)
                    root.activeTaskItem.actionQuit()
            }
        }
    }

    fullRepresentation: PlasmaExtras.Representation {
        id: fullRepresentationItem
        collapseMarginsHint: true

        TapHandler {
            onTapped: {
                windowMenu.open()
            }
        }
    }
}
