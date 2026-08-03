pragma Singleton
import Quickshell
import "."

Singleton {
    id: root

    function doLayout(layoutAlgorithm, windowList, width, height) {
        var doLayout = null;
        switch (layoutAlgorithm) {
        default:
            doLayout = SmartGridLayout.doLayout;
        }

        return doLayout(windowList, width, height);
    }
}
