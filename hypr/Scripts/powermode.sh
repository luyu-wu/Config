#!/bin/bash

current=$(powerprofilesctl get | tr -d '\n')

case "$current" in
    "power-saver")
        next="balanced"
        ;;
    "balanced")
        next="performance"
        ;;
    "performance")
        next="power-saver"
        ;;
    *)
        next="balanced"
        ;;
esac

case "$next" in
    "power-saver")
        swayosd-client  --custom-message "Battery" --custom-icon "battery-010"
        ;;
    "balanced")
        swayosd-client  --custom-message "Balanced" --custom-icon "battery-050"
        ;;
    "performance")
        swayosd-client --custom-message "Performance" --custom-icon "battery-090-charging"
        ;;
esac

powerprofilesctl set "$next"
