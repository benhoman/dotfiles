#!/bin/bash
PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ -z "$PERCENTAGE" ]; then exit 0; fi

case "$PERCENTAGE" in
    9[0-9]|100) ICON="" ;;
    [6-8][0-9])  ICON="" ;;
    [3-5][0-9])  ICON="" ;;
    [1-2][0-9])  ICON="" ;;
    *)           ICON="" ;;
esac

COLOR=0xff7a7a7a
if [ -n "$CHARGING" ]; then
    ICON=""
    COLOR=0xff9ed072
fi
if [ "$PERCENTAGE" -le 15 ] && [ -z "$CHARGING" ]; then
    COLOR=0xfffc5d7c
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
