import icons from '../icons.js';
import Clock from '../misc/Clock.js';
import * as vars from '../variables.js';
const { Box, Label, Widget, CircularProgress, Icon } = ags.Widget;



export default () => Box({
    vertical: true,
    className: 'datemenu',
    children: [
        Clock({ format: '%H:%M' }),
        Label({
            connections: [[vars.uptime, label => {
                label.label = `uptime: ${vars.uptime.value}`;
            }]],
        }),
        Box({
            className: 'calendar',
            children: [
                Widget({
                    type: imports.gi.Gtk.Calendar,
                    hexpand: true,
                    halign: 'center',
                }),
            ],
        }),
    ],
});
