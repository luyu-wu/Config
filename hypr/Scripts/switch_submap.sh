#!/bin/bash

id=$(hyprctl -j activewindow | grep -o '"id": [0-9]\+' | grep -o '[0-9]\+')

if [ "$id" -gt 0 ]; then
    # If id is a positive number, execute dispatch submap normal
    hyprctl dispatch submap normal
    echo return to normal
fi
