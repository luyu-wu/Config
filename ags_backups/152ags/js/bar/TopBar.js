import Workspaces from './buttons/Workspaces.js';
import MediaIndicator from './buttons/MediaIndicator.js';
import DateButton from './buttons/DateButton.js';
import NotificationIndicator from './buttons/NotificationIndicator.js';
import SysTray from './buttons/SysTray.js';
import SystemIndicators from './buttons/SystemIndicators.js';
import PowerMenu from './buttons/PowerMenu.js';
import ScreenRecord from './buttons/ScreenRecord.js';
import BatteryBar from './buttons/BatteryBar.js';
import SubMenu from './buttons/SubMenu.js';
import { SystemTray, Widget, Variable } from '../imports.js';
import { Notifications, Mpris, Battery } from '../imports.js';
import Recorder from '../services/screenrecord.js';

const submenuItems = Variable(1);
SystemTray.connect('changed', () => {
    submenuItems.setValue(SystemTray.items.length + 1);
});

const Start = () => Widget.Box({
    class_name: 'start',
    children: [
        Workspaces(),
        Widget.Box({ hexpand: true }),
        NotificationIndicator(),
    ],
});

const Center = () => Widget.Box({
    class_name: 'center',
    children: [
        DateButton(),
    ],
});

const End = () => Widget.Box({
    class_name: 'end',
    children: [
        MediaIndicator(),
        Widget.Box({ hexpand: true }),

        SubMenu({
            items: submenuItems,
            children: [
                SysTray(),
            ],
        }),

        ScreenRecord(),
        SystemIndicators(),
        BatteryBar(),
        PowerMenu(),
    ],
});

export default monitor => Widget.Window({
    name: `bar${monitor}`,
    exclusive: true,
    monitor,
    anchor: ['top', 'left', 'right'],
    child: Widget.CenterBox({
        class_name: 'panel',
        start_widget: Start(),
        center_widget: Center(),
        end_widget: End(),
    }),
});
