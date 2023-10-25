const { App } = ags;
const { Hyprland } = ags.Service;
const { execAsync } = ags.Utils;

const noAlphaignore = ['verification', 'powermenu', 'lockscreen'];

export default function({
    wm_gaps,
    border_width,
    hypr_active_border,
    hypr_inactive_border,
    radii,
    drop_shadow,
    bar_style,
    layout,
}) {
    try {
        App.instance.connect('config-parsed', () => {
            for (const [name] of App.windows) {
                execAsync(['hyprctl', 'keyword', 'layerrule', `unset, ${name}`]).then(() => {
                    execAsync(['hyprctl', 'keyword', 'layerrule', `blur, ${name}`]);
                    if (!noAlphaignore.every(skip => !name.includes(skip)))
                        return;

                    execAsync(['hyprctl', 'keyword', 'layerrule', `ignorealpha 0.6, ${name}`]);
                });
            }
        });

    } catch (error) {
        console.error(error);
    }
}
