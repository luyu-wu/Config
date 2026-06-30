import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

PlasmoidItem {
    id: root

    function tempDisplay(celsius) {
        if (celsius === undefined || celsius === null || isNaN(celsius))
            return "N/A";
        var c = parseFloat(celsius);
        if (plasmoid.configuration.temperatureUnit === "F")
            return (c * 9 / 5 + 32).toFixed(1) + " °F";
        return c.toFixed(1) + " °C";
    }

    function pwrDisplay(pwr) {
        return parseFloat(gpuPower.value).toFixed(1) + " W";
    }

    function pct(v) {
        if (v === undefined || isNaN(v))
            return "…";
        return parseFloat(v).toFixed(1) + "%";
    }

    function fmtBytes(bytes, suffix) {
        if (bytes === undefined || isNaN(bytes))
            return "…";
        var b = parseFloat(bytes);
        var units = ["B", "KB", "MB", "GB", "TB"];
        var i = 0;
        while (b >= 1024 && i < units.length - 1) {
            b /= 1024;
            i++;
        }
        return b.toFixed(1) + " " + units[i] + (suffix || "");
    }

    function fmtFreq(hz) {
        if (hz === undefined || isNaN(hz))
            return "…";
        var f = parseFloat(hz);
        if (f >= 1e9)
            return (f / 1e9).toFixed(2) + " GHz";
        if (f >= 1e6)
            return (f / 1e6).toFixed(0) + " MHz";
        return f.toFixed(0) + " MHz";
    }

    /// Sensors

    // CPU
    Sensors.Sensor {
        id: cpuUsage
        sensorId: "cpu/all/usage"
        enabled: plasmoid.configuration.showProcessor
    }
    Sensors.Sensor {
        id: cpuFreq
        sensorId: "cpu/all/averageFrequency"
        enabled: plasmoid.configuration.showProcessor
    }
    Sensors.Sensor {
        id: cpuTemp
        sensorId: "cpu/all/averageTemperature"
        enabled: plasmoid.configuration.showTemperature
    }
    Sensors.Sensor {
        id: cpuPower
        sensorId: "cpu/all/power"
        enabled: plasmoid.configuration.showProcessor
    }

    // Memory
    Sensors.Sensor {
        id: memUsed
        sensorId: "memory/physical/used"
        enabled: plasmoid.configuration.showMemory
    }
    Sensors.Sensor {
        id: memTotal
        sensorId: "memory/physical/total"
        enabled: plasmoid.configuration.showMemory
    }
    Sensors.Sensor {
        id: memPct
        sensorId: "memory/physical/usedPercent"
        enabled: plasmoid.configuration.showMemory
    }

    // Network (aggregate across all interfaces)
    Sensors.Sensor {
        id: netDown
        sensorId: "network/all/downloadTotal"
        enabled: plasmoid.configuration.showNetwork
    }
    Sensors.Sensor {
        id: netUp
        sensorId: "network/all/uploadTotal"
        enabled: plasmoid.configuration.showNetwork
    }

    // Battery
    Sensors.Sensor {
        id: batPct
        sensorId: "power/00B9/chargePercentage"
        enabled: plasmoid.configuration.showBattery
    }
    Sensors.Sensor {
        id: batPower
        sensorId: "power/00B9/chargeRate"
        enabled: plasmoid.configuration.showBattery
    }

    // Fan (aggregate)
    Sensors.Sensor {
        id: fanSpeed
        sensorId: "fan/all/averageSpeed"
        enabled: plasmoid.configuration.showFan
    }

    // GPU
    Sensors.Sensor {
        id: gpuUsage
        sensorId: "gpu/all/usage"
        enabled: plasmoid.configuration.showGpu
    }
    Sensors.Sensor {
        id: gpuVram
        sensorId: "gpu/all/usedVram"
        enabled: plasmoid.configuration.showGpu
    }
    Sensors.Sensor {
        id: gpuTemp
        sensorId: "gpu/gpu1/temperature"
        enabled: plasmoid.configuration.showGpu
    }
    Sensors.Sensor {
        id: gpuPower
        sensorId: "gpu/gpu1/power1"
        enabled: plasmoid.configuration.showGpu
    }

    // ─── Compact representation

    compactRepresentation: Item {
        Layout.minimumWidth: compactRow.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.fillHeight: true

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        Row {
            id: compactRow
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            //Kirigami.Icon {
            //    source: "utilities-system-monitor"
            //    width: Kirigami.Units.iconSizes.small
            //    height: Kirigami.Units.iconSizes.small
            //    anchors.verticalCenter: parent.verticalCenter
            //    visible: !plasmoid.configuration.compactView
            //}

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                PlasmaComponents.Label {
                    visible: plasmoid.configuration.showProcessor && cpuUsage.value !== undefined
                    text: "     " + pct(cpuUsage.value)
                    font.pixelSize: Kirigami.Units.gridUnit * 0.7
                }
                PlasmaComponents.Label {
                    visible: plasmoid.configuration.showMemory && memPct.value !== undefined
                    text: "    " + pwrDisplay(batPower.value)
                    font.pixelSize: Kirigami.Units.gridUnit * 0.7
                }
            }
        }
    }

    // Full

    fullRepresentation: PlasmaExtras.Representation {
        collapseMarginsHint: true

        header: PlasmaExtras.PlasmoidHeading {
            PlasmaExtras.Heading {
                level: 1
                text: "System Info"
            }
        }

        contentItem: Controls.ScrollView {
            clip: true

            ColumnLayout {
                width: parent ? parent.width : 0
                spacing: 10
                Item {
                    height: Kirigami.Units.smallSpacing
                }

                // CPU
                SectionHeader {
                    text: "CPU"
                    visible: plasmoid.configuration.showProcessor
                }
                SensorRow {
                    label: "Usage"
                    value: pct(cpuUsage.value)
                    visible: plasmoid.configuration.showProcessor
                }
                SensorRow {
                    label: "Frequency"
                    value: fmtFreq(cpuFreq.value)
                    visible: plasmoid.configuration.showProcessor
                }
                SensorRow {
                    label: "Temperature"
                    value: tempDisplay(cpuTemp.value)
                    visible: plasmoid.configuration.showProcessor && cpuTemp.value !== undefined
                }
                SensorRow {
                    label: "Power"
                    value: pwrDisplay(cpuPower.value)
                    visible: plasmoid.configuration.showProcessor && cpuPower.value !== undefined
                }

                // Memory
                SectionHeader {
                    text: "Memory"
                    visible: plasmoid.configuration.showMemory
                }
                SensorRow {
                    label: "Usage"
                    value: pct(memPct.value)
                    visible: plasmoid.configuration.showMemory
                }
                SensorRow {
                    label: "Used"
                    value: fmtBytes(memUsed.value)
                    visible: plasmoid.configuration.showMemory
                }
                SensorRow {
                    label: "Total"
                    value: fmtBytes(memTotal.value)
                    visible: plasmoid.configuration.showMemory
                }

                // Fan (only show if detected)
                SectionHeader {
                    text: "Fan"
                    visible: plasmoid.configuration.showFan && fanSpeed.value !== undefined
                }
                SensorRow {
                    label: "Speed"
                    value: fanSpeed.value !== undefined ? Math.round(fanSpeed.value) + " RPM" : "…"
                    visible: plasmoid.configuration.showFan && fanSpeed.value !== undefined
                }

                // Network
                SectionHeader {
                    text: "Network"
                    visible: plasmoid.configuration.showNetwork
                }
                SensorRow {
                    label: "Download"
                    value: fmtBytes(netDown.value, "/s")
                    visible: plasmoid.configuration.showNetwork
                }
                SensorRow {
                    label: "Upload"
                    value: fmtBytes(netUp.value, "/s")
                    visible: plasmoid.configuration.showNetwork
                }

                // Battery
                SectionHeader {
                    text: "Battery"
                    visible: plasmoid.configuration.showBattery && batPct.value !== undefined
                }
                SensorRow {
                    label: "Charge"
                    value: pct(batPct.value)
                    visible: plasmoid.configuration.showBattery && batPct.value !== undefined
                }
                SensorRow {
                    label: "Power"
                    value: pwrDisplay(batPower.value)
                    visible: plasmoid.configuration.showBattery && batPower.value !== undefined
                }

                // GPU
                SectionHeader {
                    text: "GPU"
                    visible: plasmoid.configuration.showGpu && gpuUsage.value !== undefined
                }
                SensorRow {
                    label: "Usage"
                    value: pct(gpuUsage.value)
                    visible: plasmoid.configuration.showGpu && gpuUsage.value !== undefined
                }
                SensorRow {
                    label: "Memory Used"
                    value: fmtBytes(gpuVram.value)
                    visible: plasmoid.configuration.showGpu && gpuVram.value !== undefined
                }
                SensorRow {
                    label: "Temperature"
                    value: tempDisplay(gpuTemp.value)
                    visible: plasmoid.configuration.showGpu && gpuTemp.value !== undefined
                }
                SensorRow {
                    label: "Power"
                    value: pwrDisplay(gpuPower.value)
                    visible: plasmoid.configuration.showGpu
                }

                Item {
                    height: Kirigami.Units.smallSpacing
                }
            }
        }
    }

    // Reusable components

    component SectionHeader: Kirigami.Separator {
        property string text: ""
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.mediumSpacing

        PlasmaComponents.Label {
            anchors {
                left: parent.left
                leftMargin: Kirigami.Units.smallSpacing
                verticalCenter: parent.verticalCenter
            }
            text: parent.text
            font.bold: true
            font.pixelSize: Kirigami.Units.gridUnit * 0.75
            color: Kirigami.Theme.disabledTextColor
        }
    }

    component SensorRow: RowLayout {
        property string label: ""
        property string value: "…"
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing * 2
        Layout.rightMargin: Kirigami.Units.smallSpacing * 2
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            text: label
            color: Kirigami.Theme.disabledTextColor
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        PlasmaComponents.Label {
            text: value
            horizontalAlignment: Text.AlignRight
            Layout.minimumWidth: Kirigami.Units.gridUnit * 5
        }
    }
}
