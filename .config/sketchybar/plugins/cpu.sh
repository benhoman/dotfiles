#!/bin/bash
CPU=$(top -l 1 -n 0 2>/dev/null | grep "CPU usage" | awk '{print int($3)}')
if [ -n "$CPU" ]; then
    COLOR=0xff7a7a7a
    [ "$CPU" -ge 80 ] && COLOR=0xfffc5d7c
    [ "$CPU" -ge 50 ] && [ "$CPU" -lt 80 ] && COLOR=0xffe7c664
    sketchybar --set "$NAME" label="${CPU}%" label.color="$COLOR"
fi
