import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

ColumnLayout{
    required property var list
    property alias heading: head.text
    property alias subsAllowed: subsInfo.visible
    RowLayout{
        Kirigami.Heading{
            id: head
            level: 2
        }
        PC3.ToolButton{
            id: subsInfo
            icon.name: "documentinfo"
            PC3.ToolTip { text: i18n("<b>Substitutions allowed:</b><p>%a: Application Name<p>%w: Window Title<p>%q : Activity Name") }
        }
    }
    PC3.TextArea{
        Layout.fillWidth: true
        Layout.fillHeight: true
        text: listToText(list)
        onTextChanged: list = textAreaToList(text)
        Flickable {
            onContentYChanged: {
                replace.flickableItem.contentY    = flickableItem.contentY
                titleMatch.flickableItem.contentY = flickableItem.contentY
            }
        }
    }
}
