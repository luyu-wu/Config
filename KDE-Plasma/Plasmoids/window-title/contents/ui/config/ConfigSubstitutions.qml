import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.iconthemes as KIconThemes
import org.kde.ksvg as KSvg

Kirigami.ScrollablePage {
    id: subsPage
    function textAreaToList(text) { return text.split('\n') }
    function listToText(list) { return list.join('\n') }
    readonly property alias cfg_subsMatchApp  : subsPage.nameMatches
    readonly property alias cfg_subsMatchTitle: subsPage.titleMatches
    readonly property alias cfg_subsReplace   : subsPage.replacements
    property var nameMatches
    property var titleMatches
    property var replacements
    header:Kirigami.InlineMessage {
        Layout.fillWidth: true
        text: i18n("Length of lists is not equal")
        visible: !(nameMatches.length == titleMatches.length && titleMatches.length == replacements.length)
        type: Kirigami.MessageType.Warning
    }
    // TODO: Clean this, not the most elegant way to handle it!
    RowLayout{
        SubsBox{
            id: nameMatch
            heading: i18n("Application Name Match")
            subsAllowed: false
            list: nameMatches
            onListChanged: nameMatches = list
        }
        SubsBox{
            id: titleMatch
            heading: i18n("Window Title Match")
            subsAllowed: false
            list: titleMatches
            onListChanged: titleMatches = list
        }
        SubsBox{
            id: replace
            heading: i18n("Replacement")
            list: replacements
            onListChanged: replacements = list
        }
    }
}
