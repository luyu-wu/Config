# macos-titlebar

GTK3 and GTK4 CSS stylesheets that apply macOS-style buttons over the current GTK theme without changing it. Tested with elementary OS but should work with any GNOME desktop.

**Night**

![Screenshot from 2021-11-04 17-29-06](https://user-images.githubusercontent.com/33252703/140376423-eb1c0f8a-de50-45eb-bd75-101bf5013b2d.png)


**Day**


![Screenshot from 2021-11-04 17-29-21](https://user-images.githubusercontent.com/33252703/140376484-09f15c2c-98e6-4368-a1ef-d44f3cfb8ab3.png)


## Install

```sh
sh install.sh
```

## Customizing Button Styles

To customize the button styles, you can modify the `gtk.css` files located at:

- GTK3: `~/.config/gtk-3.0/gtk.css`
- GTK4: `~/.config/gtk-4.0/gtk.css`

## Flatpak theming

Run this command to override `xdg-config` and theme buttons for Flatpak apps:

```sh
flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
flatpak override --user --filesystem=xdg-config/gtk-4.0:ro
```

To apply the entire elementary theme to Flatpak apps, you must install the current theme as a Flatpak app. To do that, use the [stylepak](https://github.com/refi64/stylepak) bash script.

Some apps may still ignore it, but the majority will work fine. Log out or reboot to apply changes.

## To uninstall

```sh
sh uninstall.sh
```

To remove Flatpak themes:
```bash
flatpak uninstall <full theme name>
```

## License

This project is licensed under the MIT License
