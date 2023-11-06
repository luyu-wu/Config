import { App, Utils } from '../../imports.js';

const noAlphaignore = ['verification', 'powermenu', 'lockscreen'];

export default function({
    wm_gaps,
    radii,
    bar_style,
    layout,
}) {
    try {
        App.connect('config-parsed', () => {
            for (const [name] of App.windows) {
                Utils.execAsync(['hyprctl', 'keyword', 'layerrule', `unset, ${name}`]).then(() => {
                    Utils.execAsync(['hyprctl', 'keyword', 'layerrule', `blur, ${name}`]);
                    if (!noAlphaignore.every(skip => !name.includes(skip)))
                        return;

                    Utils.execAsync(['hyprctl', 'keyword', 'layerrule', `ignorealpha 0.6, ${name}`]);
                });
            }
        });

        JSON.parse(Utils.exec('hyprctl -j monitors')).forEach(({ name }) => {
            if (bar_style !== 'normal') {
                switch (layout) {
                    case 'topbar':
                    case 'unity':
                        Utils.execAsync(`hyprctl keyword monitor ${name},addreserved,-${wm_gaps},0,0,0`);
                        break;

                    case 'bottombar':
                        Utils.execAsync(`hyprctl keyword monitor ${name},addreserved,0,-${wm_gaps},0,0`);
                        break;

                    default: break;
                }
            } else {
                Utils.execAsync(`hyprctl keyword monitor ${name},addreserved,0,0,0,0`);
            }
        });

        Utils.execAsync(`hyprctl keyword general:gaps_out ${wm_gaps}`);
        Utils.execAsync(`hyprctl keyword general:gaps_in ${wm_gaps / 2}`);
        Utils.execAsync(`hyprctl keyword decoration:rounding ${radii}`);
    } catch (error) {
        console.error(error);
    }
}
