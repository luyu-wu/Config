import { Clock } from '../../modules/clock.js';
import { Separator } from '../../modules/misc.js';
const { Theme, System } = ags.Service;
const { MenuItem, Menu, Box, Label, Icon, EventBox, CenterBox } = ags.Widget;

const Item = (label, icon, onActivate) => MenuItem({
    onActivate,
    child: Box({
        children: [
            Icon(icon),
            Label({
                label,
                hexpand: true,
                xalign: 0,
            }),
        ],
    }),
});

export const Desktop = props => EventBox({
    ...props,
});
