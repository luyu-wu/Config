#!/bin/bash

# Restore GTK config folders from backups or remove them if no backup exists
for dir in gtk-3.0 gtk-4.0; do
    if [ -d "$HOME/.config/$dir.bak" ]; then
        rm -rf "$HOME/.config/$dir"
        mv "$HOME/.config/$dir.bak" "$HOME/.config/$dir"
        echo "Restored $HOME/.config/$dir from backup"
    else
        if [ -d "$HOME/.config/$dir" ]; then
            rm -rf "$HOME/.config/$dir"
            echo "Removed $HOME/.config/$dir"
        fi
    fi
done

# Reset window controls to default
gsettings reset org.gnome.desktop.wm.preferences button-layout

echo "Uninstallation complete. Please log out and log back in to apply changes."
