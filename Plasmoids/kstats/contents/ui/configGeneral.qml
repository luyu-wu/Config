import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configRoot

    property alias cfg_updateInterval: updateIntervalSpin.value
    property alias cfg_showProcessor: showProcessorCheck.checked
    property alias cfg_showMemory: showMemoryCheck.checked
    property alias cfg_showNetwork: showNetworkCheck.checked
    property alias cfg_showBattery: showBatteryCheck.checked
    property alias cfg_showFan: showFanCheck.checked
    property alias cfg_showGpu: showGpuCheck.checked
    property alias cfg_compactView: compactViewCheck.checked
    property string cfg_temperatureUnit: "C"

    Kirigami.FormLayout {

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Refresh")
        }

        Controls.SpinBox {
            id: updateIntervalSpin
            Kirigami.FormData.label: i18n("Update interval (seconds):")
            from: 1
            to: 60
            stepSize: 1
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Sensors to Show")
        }

        Controls.CheckBox {
            id: showProcessorCheck
            Kirigami.FormData.label: i18n("Processor")
            text: i18n("Show processor stats")
        }
        Controls.CheckBox {
            id: showMemoryCheck
            Kirigami.FormData.label: i18n("Memory")
            text: i18n("Show memory stats")
        }
        Controls.CheckBox {
            id: showFanCheck
            Kirigami.FormData.label: i18n("Fan")
            text: i18n("Show fan speeds")
        }
        Controls.CheckBox {
            id: showNetworkCheck
            Kirigami.FormData.label: i18n("Network")
            text: i18n("Show network speeds")
        }
        Controls.CheckBox {
            id: showBatteryCheck
            Kirigami.FormData.label: i18n("Battery")
            text: i18n("Show battery info")
        }
        Controls.CheckBox {
            id: showGpuCheck
            Kirigami.FormData.label: i18n("GPU")
            text: i18n("Show GPU stats")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Display Options")
        }

        Controls.CheckBox {
            id: compactViewCheck
            Kirigami.FormData.label: i18n("Compact view")
            text: i18n("Hide icon in panel")
        }

        Controls.ComboBox {
            id: temperatureUnitCombo
            Kirigami.FormData.label: i18n("Temperature unit:")
            model: ["°C (Celsius)", "°F (Fahrenheit)"]
            currentIndex: configRoot.cfg_temperatureUnit === "F" ? 1 : 0
            onCurrentIndexChanged: configRoot.cfg_temperatureUnit = (currentIndex === 1 ? "F" : "C")
        }
    }
}
