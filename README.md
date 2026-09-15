# Config Files

## About
hyprland config files that value elegance and lightweightness over bulky and slow animations.
workflow is build to be intuitive and easily customizeable :)
## Screenshots

<img width="2256" height="1504" alt="image" src="https://github.com/user-attachments/assets/d9c46940-f813-4aeb-a741-8ab021fa59b0" />
[High Sierra - Quickshell]

<img width="2256" height="1504" alt="screenshot-2026-03-17_01-07-55" src="https://github.com/user-attachments/assets/586e838d-ded8-4fbc-a626-3df5cd698c4a" />
[High Sierra - Waybar]

![update](https://github.com/user-attachments/assets/394c139d-99ee-4355-adc6-e5a116f68ec2)
[Nature]

![image](https://github.com/luyu-wu/Config/assets/116970666/32474c1b-b00f-4191-9662-a6b0b7f282b5)
[Adwaita]

![image](https://github.com/luyu-wu/Config/assets/116970666/974876cb-2018-4584-8663-e66a40dbdffa)
[Ascension]

![image](https://github.com/luyu-wu/Config/assets/116970666/d6f0f849-df94-4bd8-8f35-c07e3d81da66)
[Finished Light Mode Release]

<!-- ![2023-12-23-132749_hyprshot](https://github.com/luyu-wu/Config/assets/116970666/4a6c67d1-d88b-4a78-8ff7-740f403eb6d2)
[Finished Light Mode Release] -->


## Features
- Expressive tiled window manager experience
- Intuitive keybinds for screenshots, launchers, tiling, and more!
- Fully custom rofi launcher and waybar
- Low resource utilization for low-battery utilization (no JS >:), 0% idle usage
- Low memory usage (once again no JS)
- Custom bezier curves for smooth animations
- Consistent theming across dotfile
- Custom binaries for manipulating hyprland (CTM <3)
- Tons of other stuff!!

## Screenshot overlay

`SUPER SHIFT S` opens the region screenshot overlay. It is a module of the main
quickshell instance (`quickshell/screenshot/`) rather than a separate
quickshell process, so it costs nothing when idle and shares the running
compositor connection.

It is bound through Hyprland's global shortcut protocol, so the key dispatches
straight into the running shell with no process spawn and no IPC round trip:

| Bind | Global shortcut | Behaviour |
| --- | --- | --- |
| `SUPER SHIFT S` | `quickshell:region` | Save to `~/Pictures/Screenshots`, copy to clipboard |
| `Print` | `quickshell:regionTemp` | Copy to clipboard only |
| - | `quickshell:regionEdit` | Open satty to annotate before saving |

Inside the overlay:

| Key | Behaviour |
| --- | --- |
| drag | Capture the dragged region |
| click | Capture the whole focused screen |
| `S` | Capture the whole focused screen |
| `E` | Toggle the satty/annotation mode |
| `T` | Toggle copy-only mode |
| `Esc` / `Q` / right-click | Dismiss without saving |

The frozen desktop is grabbed with `grim` once at startup, replacing the
`screencopy` view the standalone version used (a screencopy surface cannot
render a shader on top of itself).

## Packages
in the packages.txt or smth, flatpaks r in the flatpak one! (this hasn't been updated in years, best bet is just finding what you need the hard way)

(non-exhaustive list, i just forget the rest of the important dependencies, u prob need nerd-fonts or smth)

## Credits

all the great tools that made this possible at all :D
