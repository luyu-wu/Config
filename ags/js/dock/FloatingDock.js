const { EventBox, Window, Box, Revealer } = ags.Widget;

export default monitor => Window({
    monitor,
    name: `dock${monitor}`,
    className: 'floating-dock',
});

