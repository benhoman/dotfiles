#!/bin/bash
# OmniWM workspace watcher — bridges omniwmctl events to sketchybar
# Runs as a background process started by sketchybarrc
#
# Subscribes to active-workspace changes via omniwmctl and triggers
# sketchybar's omniwm_workspace_change event with the focused workspace.

# Wait for OmniWM IPC to be available
# # buffer complete JSON objects before parsing.

# Wait for OmniWM IPC to be available
sleep 2

# Kill any existing watcher for this user
pkill -f "omniwmctl subscribe active-workspace" 2>/dev/null

# Subscribe and buffer multi-line JSON into complete objects
# jq --unbuffered reads the pretty-printed stream and emits one line per event
# Note: events use .workspace (singular), queries use .workspaces[] (array)
omniwmctl subscribe active-workspace --no-send-initial 2>/dev/null \
    | jq --unbuffered -r 'select(.kind == "event") | .result.payload.workspace.rawName // .result.payload.workspace.displayName // empty' \
    | while IFS= read -r WORKSPACE; do
        if [ -n "$WORKSPACE" ]; then
            sketchybar --trigger omniwm_workspace_change FOCUSED_WORKSPACE="$WORKSPACE"
        fi
    done &

# Initial sync — query current focused workspace
sleep 1
CURRENT=$(omniwmctl query workspaces --focused 2>/dev/null | jq -r '.result.payload.workspaces[0].rawName // .result.payload.workspaces[0].displayName // empty' 2>/dev/null)
if [ -n "$CURRENT" ]; then
    sketchybar --trigger omniwm_workspace_change FOCUSED_WORKSPACE="$CURRENT"
fi

wait
