import * as mpris from '../../misc/mpris.js';
const { Mpris } = ags.Service;
const { Box, CenterBox } = ags.Widget;



const TextBox = player => Box({
    children: [
        mpris.CoverArt(player, {
            halign: 'end',
            hexpand: false,
            child: Box({
                className: 'shader',
                hexpand: true,
            }),
        }),
        Box({
            hexpand: true,
            vertical: true,
            className: 'labels',
            children: [
                mpris.TitleLabel(player, {
                    xalign: 0,
                    justification: 'left',
                    wrap: true,
                }),
                mpris.ArtistLabel(player, {
                    xalign: 0,
                    justification: 'left',
                    wrap: true,
                }),
            ],
        }),
    ],
});

const PlayerBox = player => Box({
    className: `player ${player.name}`,
    children: [
        mpris.BlurredCoverArt(player, {
            className: 'cover-art-bg',
            hexpand: true,
            children: [Box({
                className: 'shader',
                hexpand: true,
                vertical: true,
                children: [
                    TextBox(player),
                    mpris.PositionSlider(player),
                    //Footer(player),
                ],
            })],
        }),
    ],
});

export default () => Box({
    vertical: true,
    className: 'media',
    properties: [['players', new Map()]],
    connections: [
        [Mpris, (box, busName) => {
            if (!busName || box._players.has(busName))
                return;

            const player = Mpris.getPlayer(busName);
            box._players.set(busName, PlayerBox(player));
            box.children = Array.from(box._players.values());
        }, 'player-added'],
        [Mpris, (box, busName) => {
            if (!busName || !box._players.has(busName))
                return;

            box._players.delete(busName);
            box.children = Array.from(box._players.values());
        }, 'player-closed'],
    ],
});
