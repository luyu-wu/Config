const { lookUpIcon } = ags.Utils;
const { Box, Revealer, Stack, Icon, Window } = ags.Widget;
import FontIcon from '../misc/FontIcon.js';
import Progress from '../misc/Progress.js';
import Indicator from '../services/onScreenIndicator.js';

export const OnScreenIndicator = ({ height = 15, width = 500 } = {}) => Box({
    className: 'indicator',
    style: 'padding: 1px;',
    children: [Revealer({
        transition: 'slide_down',
        connections: [[Indicator, (revealer, value) => {
            revealer.revealChild = value > -1;
        }]],
        child: Progress({
            width,
            height,
            vertical: false,
            connections: [[Indicator, (progress, value) => progress.setValue(value)]],
            child: Stack({
                valign: 'start',
                halign: 'center',
                hexpand: true,

                connections: [[Indicator, (stack, _v, name) => {
                    stack.shown = `${!!lookUpIcon(name)}`;
                }]],
            }),
        }),
    })],
});

export default monitor => Window({
    name: `indicator${monitor}`,
    monitor,
    className: 'indicator',
    layer: 'overlay',
    anchor: ['top'],
    child: OnScreenIndicator(),
});
