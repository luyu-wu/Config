
import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-display-color"
         source: "config/ConfigAppearance.qml"
    }
    ConfigCategory {
         name: i18n("Behavior")
         icon: "preferences-desktop"
         source: "config/ConfigBehavior.qml"
    }
    ConfigCategory {
        name: i18n("Substitutions")
        icon: "edit-find-replace"
        source: "config/ConfigSubstitutions.qml"
    }
}
