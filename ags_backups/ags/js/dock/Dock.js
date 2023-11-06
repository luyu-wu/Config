import icons from '../icons.js';
import Separator from '../misc/Separator.js';
import options from '../options.js';
const { Hyprland, Applications } = ags.Service;
const { execAsync } = ags.Utils;
const { Box, Button, Icon, Overlay } = ags.Widget;

const pinned = [
];



const Taskbar = skip => Box({
    properties: [['apps', Applications.query('')]],
});

const PinnedApps = list => Box({
    className: 'pins',
    homogeneous: true,
    children: list
        .map(term => ({ app: Applications.query(term)?.[0], term }))
        .filter(({ app }) => app)
        .map(({ app, term = true }) => AppButton({
            icon: app.iconName,
            onPrimaryClick: () => {
                for (const client of Hyprland.clients) {
                    if (client.class.toLowerCase().includes(term)) {
                        execAsync(`hyprctl dispatch focuswindow address:${client.address}`).catch(print);
                        return;
                    }
                }

                app.launch();
            },
            onMiddleClick: () => app.launch(),
            tooltipText: app.name,
            connections: [[Hyprland, button => {
                let running = false;
                for (const client of Hyprland.clients) {
                    if (client.class.toLowerCase().includes(term))
                        running = client;
                }

                button.toggleClassName('nonrunning', !running);
                button.toggleClassName('focused', Hyprland.active.client.address === running.address?.substring(2));
                button.set_tooltip_text(running ? running.title : app.name);
            }]],
        })),
});

export default () => {
    const taskbar = Taskbar(pinned);
};
