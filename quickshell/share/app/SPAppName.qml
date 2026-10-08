pragma Singleton
import Quickshell
import QtQuick

Singleton {
  function getAppName(wmclass) {
    var entry = DesktopEntries.byId(wmclass)
    if (entry) return entry.name
    return wmclass
  }

  function getAppExec(wmclass) {
    var entry = DesktopEntries.byId(wmclass)
    if (entry) return entry.execString
    return wmclass
  }
}
