#!/bin/bash

# Butler publish script for Sky Drop
# Usage: ./publish_to_itch.sh [channel]
# Channels: html5, windows, linux, mac

CHANNEL=${1:-html5}
ITCH_USER=${ITCH_USER:-"yourusername"}
ITCH_GAME=${ITCH_GAME:-"sky-drop"}
VERSION=$(cat VERSION 2>/dev/null || echo "1.0.0")

echo "Publishing Sky Drop v${VERSION} to itch.io..."
echo "Channel: ${CHANNEL}"
echo "User: ${ITCH_USER}"
echo "Game: ${ITCH_GAME}"

# Check if butler is installed
if ! command -v butler &> /dev/null; then
    echo "Butler not found. Installing..."
    curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
    unzip butler.zip
    chmod +x butler
    BUTLER="./butler"
else
    BUTLER="butler"
fi

# Determine build path based on channel
case $CHANNEL in
    html5)
        BUILD_PATH="build/html5"
        ;;
    windows)
        BUILD_PATH="build/windows"
        ;;
    linux)
        BUILD_PATH="build/linux"
        ;;
    mac)
        BUILD_PATH="build/mac"
        ;;
    *)
        echo "Unknown channel: $CHANNEL"
        exit 1
        ;;
esac

# Check if build exists
if [ ! -d "$BUILD_PATH" ]; then
    echo "Build not found at $BUILD_PATH"
    echo "Please export from Godot first"
    exit 1
fi

# Push to itch.io
echo "Pushing to ${ITCH_USER}/${ITCH_GAME}:${CHANNEL}..."
$BUTLER push "$BUILD_PATH" "${ITCH_USER}/${ITCH_GAME}:${CHANNEL}" --userversion="$VERSION"

echo "Done! Check https://${ITCH_USER}.itch.io/${ITCH_GAME}"