import Separator from '../misc/Separator.js';
import Theme from '../services/theme/theme.js';
import PowerMenu from '../services/powermenu.js';
import Clock from '../misc/Clock.js';
import icons from '../icons.js';
const { openWindow } = ags.App;
const { MenuItem, Menu, Box, Label, Icon, EventBox, CenterBox, Window, Widget } = ags.Widget;

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

const Desktop = () => EventBox({
    onSecondaryClick: (_, event) => Menu({
        className: 'desktop-menu',
        children: [
            MenuItem({
                child: Box({
                    children: [
                        Icon(icons.powermenu.shutdown),
                        Label({
                            label: 'System',
                            hexpand: true,
                            xalign: 0,
                        }),
                    ],
                }),
                submenu: Menu({
                    children: [
                        Item('Shutdown', icons.powermenu.shutdown, () => PowerMenu.action('shutdown')),
                        Item('Log Out', icons.powermenu.logout, () => PowerMenu.action('logout')),
                        Item('Reboot', icons.powermenu.reboot, () => PowerMenu.action('reboot')),
                        Item('Sleep', icons.powermenu.sleep, () => PowerMenu.action('reboot')),
                    ],
                }),
            }),
            Item('Applications', icons.apps.apps, () => openWindow('applauncher')),
            Widget({ type: imports.gi.Gtk.SeparatorMenuItem }),
            Item('Settings', icons.settings, Theme.openSettings),
        ],
    }).popup_at_pointer(event),
    onMiddleClick: print,
});

export default monitor => Window({
    monitor,
    name: `desktop${monitor}`,
    layer: 'background',
    className: 'desktop',
    anchor: ['top', 'bottom', 'left', 'right'],
    child: Desktop(),
});
