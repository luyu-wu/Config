#!/bin/sh
if pgrep -x rofi; then
    killall rofi
else
    rofi -show drun
fi
