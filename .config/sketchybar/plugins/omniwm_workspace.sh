#!/bin/bash
# Workspace indicator — highlights the focused workspace
# Triggered by omniwm_workspace_change event with FOCUSED_WORKSPACE env var

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" \
        background.drawing=on \
        background.color=0xffaca3a3 \
        label.color=0xff151515
else
    sketchybar --set "$NAME" \
        background.drawing=off \
        label.color=0xff7a7a7a
fi
