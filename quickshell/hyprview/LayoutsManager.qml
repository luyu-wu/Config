pragma Singleton
import Quickshell

Singleton {
    id: root

    function doLayout(windowList, outerWidth, outerHeight) {
        var N = windowList.length;
        if (N === 0)
            return [];
        if (outerWidth <= 0 || outerHeight <= 0)
            return [];

        var gap = Math.min(outerWidth * 0.03, outerHeight * 0.03);

        var contentScale = 0.9;
        var usableW = outerWidth * contentScale;
        var usableH = outerHeight * contentScale;

        var TARGET_ASPECT = 16.0 / 9.0;
        var bestCols = 1;
        var bestRows = 1;
        var bestScale = 0;

        for (var cols = 1; cols <= N; cols++) {
            var rows = Math.ceil(N / cols);

            var availW = usableW - gap * (cols - 1);
            var availH = usableH - gap * (rows - 1);

            if (availW <= 0 || availH <= 0)
                continue;
            var cellW = availW / cols;
            var cellH = availH / rows;

            var scaleW = cellW / TARGET_ASPECT;
            var scaleH = cellH / 1.0;
            var currentScale = Math.min(scaleW, scaleH);

            if (currentScale > bestScale) {
                bestScale = currentScale;
                bestCols = cols;
                bestRows = rows;
            }
        }

        // --- 2. REAL CELL DIMENSIONS ---
        var finalAvailW = usableW - gap * (bestCols - 1);
        var finalAvailH = usableH - gap * (bestRows - 1);
        var maxCellW = finalAvailW / bestCols;
        var maxCellH = finalAvailH / bestRows;

        // --- 3. PLACEMENT (CENTERED IN THE FULL AREA) ---
        var totalGridContentH = bestRows * maxCellH + (bestRows - 1) * gap;
        var startOffsetY = (outerHeight - totalGridContentH) / 2;

        var result = [];

        for (var r = 0; r < bestRows; r++) {
            var rowItems = [];
            var startIndex = r * bestCols;
            var endIndex = Math.min(startIndex + bestCols, N);

            if (startIndex >= N)
                break;
            var totalRowContentWidth = 0;

            // Phase 3a: size each thumbnail to fit its cell, preserving aspect.
            for (var i = startIndex; i < endIndex; i++) {
                var item = windowList[i];
                var w0 = (item.width && item.width > 0) ? item.width : 100;
                var h0 = (item.height && item.height > 0) ? item.height : 100;

                var scale = Math.min(maxCellW / w0, maxCellH / h0);

                var thumbW = w0 * scale;
                var thumbH = h0 * scale;

                rowItems.push({
                    originalItem: item,
                    width: thumbW,
                    height: thumbH,
                    index: i,
                    col: i - startIndex
                });

                totalRowContentWidth += thumbW;
            }

            if (rowItems.length > 1) {
                totalRowContentWidth += (rowItems.length - 1) * gap;
            }

            var currentX = (outerWidth - totalRowContentWidth) / 2;
            var cellAbsY = startOffsetY + r * (maxCellH + gap);

            for (var k = 0; k < rowItems.length; k++) {
                var rItem = rowItems[k];

                var currentY = cellAbsY + (maxCellH - rItem.height) / 2;

                result.push({
                    win: rItem.originalItem.win,
                    x: currentX,
                    y: currentY,
                    width: rItem.width,
                    height: rItem.height,
                    rowIndex: r,
                    colIndex: rItem.col
                });

                currentX += rItem.width + gap;
            }
        }

        return result;
    }
}
