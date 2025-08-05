#!/bin/bash

if pgrep -x "claude" > /dev/null; then
    usage_output=$(ccusage -j 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$usage_output" ]; then
        # Get today's cost
        today=$(date +"%Y-%m-%d")
        today_cost=$(echo "$usage_output" | jq -r --arg today "$today" '.daily[] | select(.date == $today) | .totalCost // 0')
        
        # Get total cost
        total_cost=$(echo "$usage_output" | jq -r '.totals.totalCost // 0')
        
        # Format costs
        if [ -n "$today_cost" ] && [ "$today_cost" != "null" ] && [ "$today_cost" != "0" ]; then
            formatted_today=$(printf "%.2f" "$today_cost")
        else
            formatted_today="0.00"
        fi
        
        if [ -n "$total_cost" ] && [ "$total_cost" != "null" ] && [ "$total_cost" != "0" ]; then
            formatted_total=$(printf "%.2f" "$total_cost")
        else
            formatted_total="0.00"
        fi
        
        echo "{\"text\": \"\$${formatted_today}\", \"alt\": \"\$${formatted_total}\", \"tooltip\": \"Today: \$${formatted_today} | Total: \$${formatted_total} (click to toggle)\"}"
    else
        echo "{\"text\": \"-\", \"alt\": \"-\", \"tooltip\": \"Unable to get usage data\"}"
    fi
else
    echo "{\"text\": \"-\", \"alt\": \"-\", \"tooltip\": \"Claude not running\"}"
fi