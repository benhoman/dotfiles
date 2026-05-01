#!/bin/bash
# Matches your Waybar clock format: "Wednesday 14:30"
sketchybar --set "$NAME" label="$(date '+%A %H:%M')"
