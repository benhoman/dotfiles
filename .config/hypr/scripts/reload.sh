#!/usr/bin/env sh
hyprctl reload
pkill -SIGUSR2 waybar
