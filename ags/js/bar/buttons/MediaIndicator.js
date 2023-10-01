import HoverRevealer from '../../misc/HoverRevealer.js';
import * as mpris from '../../misc/mpris.js';
import options from '../../options.js';
const { Box, Label, Revealer } = ags.Widget;
const { Mpris } = ags.Service;

export const getPlayer = (name = options.preferredMpris) =>
    Mpris.getPlayer(name) || Mpris.players[0] || null;

const Indicator = ({ player, direction = 'right' } = {}) => HoverRevealer({
//const Indicator = ({ player, direction = 'right' } = {}) => Label({
    className: `media panel-button ${player.name}`,
    direction,
    onPrimaryClick: () => player.playPause(),
    onSecondaryClick: () => player.next(),
    indicator: mpris.PlayerIcon(player),
    child: Label({
        vexpand: true,
        truncate: 'end',
        maxWidthChars: 20,
        connections: [[player, label => {
            label.label = ` ${player.trackTitle} - ${player.trackArtists[0]}`;
        }]],
    }),
});

export default ({ direction } = {}) => Box({
    connections: [[Mpris, box => {
        const player = getPlayer();
        box.visible = !!player;

        if (!player) {
            box._player = null;
            return;
        }

        if (box._player === player)
            return;

        box._player = player;
        box.children = [Indicator({ player, direction })];
    }]],
});
