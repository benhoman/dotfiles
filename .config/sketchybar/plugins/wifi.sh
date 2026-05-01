#!/bin/bash
IP=$(ipconfig getifaddr en0 2>/dev/null)
if [ -n "$IP" ]; then
    sketchybar --set "$NAME" icon="󰖩" icon.color=0xff7a7a7a
else
    sketchybar --set "$NAME" icon="󰖪" icon.color=0xfffc5d7c
fi
