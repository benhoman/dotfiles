#!/bin/bash

# toggle_app_workspace.sh <special_workspace_name> <app_id> <app>
# Toggles an app between a special workspace and the current workspace

SPECIAL_WS="$1"
APP_ID="$2"
APP="$3"

if [[ -z "$SPECIAL_WS" || -z "$APP_ID" ]]; then
  echo "Usage: $0 <special_workspace_name> <app_id> <app>"
  exit 1
fi

# Get current active workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.name')

# Ensure app_running.sh is present and executable
APP_RUNNING="$HOME/.config/hypr/scripts/app_running.sh"
if [[ ! -x "$APP_RUNNING" ]]; then
  echo "Error: app_running.sh not found or not executable."
  exit 1
fi

# Launch app if not already running
$APP_RUNNING "$APP_ID" "$APP"

# Get window address for the app
WIN_ADDR=$(hyprctl clients -j | jq -r ".[] | select(.title == \"$APP_ID\"or .class == \"$APP_ID\" or .initialClass == \"$APP_ID\") | .address")

if [[ -z "$WIN_ADDR" ]]; then
  echo "Error: Could not find window address for $APP_ID"
  exit 1
fi

# Get current workspace of the app
APP_WS=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$WIN_ADDR\") | .workspace.name")

# Toggle workspace
if [[ "$APP_WS" == "special:$SPECIAL_WS" ]]; then
  echo "App is on $SPECIAL_WS. Moving to current workspace: $CURRENT_WS"
  hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$WIN_ADDR"
else
  echo "App is on $APP_WS. Moving to special workspace: $SPECIAL_WS"
  hyprctl dispatch movetoworkspacesilent "special:$SPECIAL_WS,address:$WIN_ADDR"
fi
