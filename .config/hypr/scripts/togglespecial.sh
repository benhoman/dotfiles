#!/bin/bash

# Reusable Hyprland Special Workspace Script
# Usage:
#   script.sh <special_workspace_name> [app_id]

# Parameters
SPECIAL_WS="$1"
APP_ID="$2"
APP="$3"

# Configuration
TIMEOUT=10
INTERVAL=0.5

# Ensure the first argument is provided
if [[ -z "$SPECIAL_WS" ]]; then
  echo "Usage: $0 <special_workspace_name> [app_id] [app]"
  exit 1
fi

# Function to check if a window matching APP_ID exists
app_running() {
  [[ -z "$APP_ID" ]] && return 1
  hyprctl clients -j | jq -e ".[] | select(.title == \"$APP_ID\" or .class == \"$APP_ID\" or .initialClass == \"$APP_ID\")" >/dev/null
}

# Launch app if specified and not already running
if [[ -n "$APP_ID" ]]; then
  if ! app_running; then
    echo "Launching $APP_ID..."
    hyprctl dispatch exec "[workspace special:$SPECIAL_WS] uwsm app -- $APP"
    # uwsm app -- "$APP_ID"

    # # Wait for the app window to appear
    # elapsed=0
    # while ! app_running; do
    #   sleep $INTERVAL
    #   elapsed=$((elapsed + INTERVAL))
    #   if ((elapsed >= TIMEOUT)); then
    #     echo "Timeout: $APP_ID window not found."
    #     exit 1
    #   fi
    # done
    # echo "Detected running app: $APP_ID"
  else
    echo "App $APP_ID is already running."
  fi
fi

# Toggle the special workspace
echo "Toggling special workspace: $SPECIAL_WS"
hyprctl dispatch togglespecialworkspace "$SPECIAL_WS"
