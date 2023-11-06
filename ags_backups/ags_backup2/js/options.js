export default {
    // if this player is running this will be shown on panel
    preferredMpris: 'spotify',

    // number of workspaces shown on panel and overview
    workspaces: 7,

    //
    dockItemSize: 56,

    battaryBar: {
        // wether to show percentage by deafult
        showPercentage: false,

        // at what percentages should the battery-bar change color
        low: 0,
        medium: 0,
    },

    // path to read temperature from
    temperature: '/sys/class/thermal/thermal_zone0/temp',

    // at what intervals should cpu, ram, temperature refresh
    systemFetchInterval: 50000,

    // the slide down animation on quicksettings and dashboard
    windowAnimationDuration: 500,
};
