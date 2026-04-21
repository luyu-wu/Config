import QtQuick

QtObject {
    id: root

    property var source: ({})
    readonly property color accent: "#097aff"
    readonly property color accentText: "#fff"
    readonly property real dimOpacity: 0.4
    readonly property int borderRadius: 0
    readonly property int outlineThickness: 1
    readonly property real bottomMargin: 60
    readonly property bool animations: false
    readonly property string annotationTool: "satty"
    readonly property color barBackground: "#b1e4e7ef"
    readonly property color barBorder: "#fff"
    readonly property color barText: "#444"
    readonly property color barShadow: "#80000000"
    readonly property color toggleBackground: "#097aff"
    readonly property color toggleShadow: "#80000000"
    readonly property color toggleEdit: "#1ABC9C"
    readonly property color toggleTemp: "#2C66D8"
    readonly property color shareConnected: "#3498DB"
    readonly property color sharePending: "#95A5A6"
    readonly property color shareErrorIcon: "white"
    readonly property color shareErrorBackground: "#E74C3C"
    readonly property string postSaveHook: source.hooksPostSaveHook || ""
}
