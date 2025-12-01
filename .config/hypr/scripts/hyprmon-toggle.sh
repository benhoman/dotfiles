#!/usr/bin/env bash

set -euo pipefail

# State file to track current profile
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hyprmon-toggle-state"

# Usage function
usage() {
    echo "Usage: $0 {next|previous|prev}"
    echo "  next     - Switch to the next profile in the list"
    echo "  previous - Switch to the previous profile in the list"
    echo "  prev     - Alias for previous"
    exit 1
}

# Check if argument is provided
if [ $# -ne 1 ]; then
    usage
fi

# Normalize argument
case "$1" in
    next)
        direction="next"
        ;;
    previous|prev)
        direction="previous"
        ;;
    *)
        echo "Error: Invalid argument '$1'"
        usage
        ;;
esac

# Get list of profiles (one per line)
profiles=$(hyprmon --list-profiles)

# Read profiles into an array and find the active one
current_index=-1
index=0
profile_array=()

# First, build the profile array and check for asterisk marker
while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    if [[ "$line" == *" *" ]]; then
        current_index=$index
        # Remove the asterisk marker
        profile_array+=("${line% \*}")
    else
        profile_array+=("$line")
    fi
    index=$((index + 1))
done <<< "$profiles"

# If no asterisk found, try to get active profile from hyprmon command
if [ "$current_index" -eq -1 ]; then
    active_profile=$(hyprmon -active-profile 2>/dev/null || echo "")
    if [ -n "$active_profile" ] && [ "$active_profile" != "No active profile found" ]; then
        # Find the index of this profile
        for i in "${!profile_array[@]}"; do
            if [ "${profile_array[$i]}" = "$active_profile" ]; then
                current_index=$i
                break
            fi
        done
    fi
fi

# If still no active profile found, check our state file
if [ "$current_index" -eq -1 ] && [ -f "$STATE_FILE" ]; then
    last_profile=$(cat "$STATE_FILE")
    for i in "${!profile_array[@]}"; do
        if [ "${profile_array[$i]}" = "$last_profile" ]; then
            current_index=$i
            break
        fi
    done
fi

# If still no active profile, default to first one
if [ "$current_index" -eq -1 ]; then
    echo "No active profile detected, starting from first profile"
    current_index=0
fi

# Calculate total number of profiles
total_profiles=${#profile_array[@]}

# Calculate next index based on direction
if [ "$direction" = "next" ]; then
    new_index=$(( (current_index + 1) % total_profiles ))
else
    new_index=$(( (current_index - 1 + total_profiles) % total_profiles ))
fi

# Get the profile name to activate
new_profile="${profile_array[$new_index]}"

echo "Switching from '${profile_array[$current_index]}' to '$new_profile'"

# Apply the new profile
if hyprmon --profile "$new_profile"; then
    # Save the new profile to state file
    echo "$new_profile" > "$STATE_FILE"
else
    echo "Error: Failed to apply profile '$new_profile'"
    exit 1
fi
