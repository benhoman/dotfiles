#!/usr/bin/env sh
hyprctl reload
pkill waybar && hyprctl dispatch exec waybar
