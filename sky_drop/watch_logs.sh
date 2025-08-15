#!/bin/bash

# Real-time Godot log monitor
echo "=== Godot Log Monitor ==="
echo "Watching for Godot logs..."
echo ""

# Create log file if it doesn't exist
touch /home/alan/game_dev/godot/sky_drop/latest_godot.log

# Monitor multiple potential log locations
echo "Monitoring:"
echo "1. WSL shared log: /home/alan/game_dev/godot/sky_drop/latest_godot.log"
echo "2. Windows Desktop logs: /mnt/c/Users/alan/Desktop/sky_drop/logs/"
echo ""
echo "Press Ctrl+C to stop"
echo "========================"
echo ""

# Use tail to follow the log file
tail -f /home/alan/game_dev/godot/sky_drop/latest_godot.log 2>/dev/null &
TAIL_PID=$!

# Also watch for new log files in Windows directory
while true; do
    # Check for new log files every 5 seconds
    LATEST_LOG=$(ls -t /mnt/c/Users/alan/Desktop/sky_drop/logs/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ]; then
        echo "[Found log: $LATEST_LOG]"
        tail -f "$LATEST_LOG" 2>/dev/null &
        break
    fi
    sleep 5
done

wait