#!/bin/bash

OPTIONS="Shutdown\nSuspend\nLog Out\nReboot"

CHOICE=$(echo -e "$OPTIONS" | wofi --style ~/.config/wofi/style/style.css --show dmenu) 

case "$CHOICE" in
    "Shutdown")
        # Confirm the shutdown and execute
        echo "Shutting down..." && loginctl poweroff
        ;;
		"Reboot")
				# Confirm rebooting and execute
				echo "Rebooting..." && loginctl reboot
				;;
    "Suspend")
        # Confirm suspension and execute
        echo "Suspending..." && loginctl suspend
        ;;
    "Log Out")
        # Log out of the session
        echo "Logging out..." && hyprctl dispatch exit
        ;;
    *)
        # If no valid option is selected, exit the script
        exit 0
        ;;
esac

