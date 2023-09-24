import { Clock } from '../../modules/clock.js';
import { Separator } from '../../modules/misc.js';
import { Wallpaper } from '../../modules/wallpaper.js';
import * as datemenu from './datemenu.js';
import * as notifications from './notifications.js';
const { App } = ags;
const { Button, Box } = ags.Widget;


export const PanelButton = ({ format } = {}) => Button({
    className: 'dashboard panel-button',
    child: Clock({
        format,
        justification: 'center',
    }),
});

