import QtQuick 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors

Item {
    width: 640
    height: 480

    Sensors.SensorTreeModel {
        id: sensorTreeModel
    }


    // Visual flat list of all sensor IDs
    ListModel {
        id: flatSensorList
    }

    function buildFlatList(model, parentIndex, pathPrefix) {
        var rowCount = model.rowCount(parentIndex)
        for (var i = 0; i < rowCount; i++) {
            var index = model.index(i, 0, parentIndex)
            var segment = model.data(index, Qt.UserRole + 1)
            var fullPath = pathPrefix.length > 0 ? pathPrefix + "/" + segment : segment

            if (model.rowCount(index) > 0) {
                buildFlatList(model, index, fullPath)
            } else {
                flatSensorList.append({ "sensorId": fullPath })
            }
        }
    }

    Timer {
        interval: 1
        running: true
        repeat: true
        onTriggered: {
            if (sensorTreeModel.rowCount() > 0) {
                running = false
                buildFlatList(sensorTreeModel, Qt.invalid, "")
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: flatSensorList
        delegate: Text {
            text: sensorId
            font.pixelSize: 12
            font.family: "monospace"
        }
    }
}
