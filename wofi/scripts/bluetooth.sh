#!/bin/bash

# List all paired devices and extract names and MAC addresses
devices=$(bluetoothctl devices | grep -oP "Device \K\w+:\w+:\w+:\w+:\w+:\w+ (\S+)" | awk '{print $2 " - " $1}')

# Use wofi to display the list of devices and capture the selected one
selected_device=$(echo "$devices" | wofi --style ~/.config/wofi/style/style.css --show dmenu --prompt "Select Device" --width 300 --height 500 --lines 10)

# If a device is selected, connect to it
if [ -n "$selected_device" ]; then
    mac_address=$(echo "$selected_device" | awk '{print $NF}')
    bluetoothctl connect "$mac_address"
fi

