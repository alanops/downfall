#!/bin/bash

# Monitor Godot logs from Windows
# Godot typically outputs to stderr and stdout when run from command line

echo "Monitoring Godot logs..."
echo "To use this:"
echo "1. Open PowerShell/CMD on Windows"
echo "2. Navigate to Godot directory"
echo "3. Run: godot.exe --verbose --path C:\\Users\\alan\\Desktop\\sky_drop 2>&1 | wsl.exe /home/alan/game_dev/godot/sky_drop/monitor_godot.sh"
echo ""
echo "OR for the editor:"
echo "godot.exe --editor --verbose --path C:\\Users\\alan\\Desktop\\sky_drop 2>&1 | wsl.exe /home/alan/game_dev/godot/sky_drop/monitor_godot.sh"
echo ""
echo "Waiting for input..."
echo "-------------------"

# Read from stdin and display with timestamps
while IFS= read -r line; do
    echo "[$(date '+%H:%M:%S')] $line"
done