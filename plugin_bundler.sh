#!/bin/bash

# This script will go through all directories in the plugins directory next to it.
# It will zip the contents of the each directory and name the zip file 'DIRNAME.kbplugin'.
# kbplugin is for Kyber Star Wars Battlefront 2 server.

# Resolve paths from the script's directory so it works from anywhere
SCRIPT_DIR=$(cd "$(dirname "$(realpath "$0")")" && pwd)
WORKING_DIR="$SCRIPT_DIR/plugins"

if [ -f "$SCRIPT_DIR/.env" ]; then
  source "$SCRIPT_DIR/.env"
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "Error: zip is required to bundle plugins. Install it (e.g. sudo apt install zip)."
  exit 1
fi

# Remove all existing .kbplugin files before bundling
find "$WORKING_DIR" -maxdepth 1 -name "*.kbplugin" -type f -delete

# If KYBER_ENABLED_PLUGINS is not set, then define it to all directories in the working directory with a plugin.json file
if [ -z "$KYBER_ENABLED_PLUGINS" ]; then
  PLUGINS=""
  for dir in "$WORKING_DIR"/*/; do
    if [ -f "$dir/plugin.json" ]; then
      DIR_NAME=$(basename "$dir")
      PLUGINS="$PLUGINS$DIR_NAME,"
    fi
  done
  # Remove the trailing comma
  KYBER_ENABLED_PLUGINS="${PLUGINS%,}"
fi

# If KYBER_ENABLED_PLUGINS is still empty, then exit the script
if [ -z "$KYBER_ENABLED_PLUGINS" ]; then
  echo "No plugins found to bundle. Please set KYBER_ENABLED_PLUGINS in the .env file or ensure there are directories with plugin.json files."
  exit 0
fi

# Loop through the list of enabled plugins from the .env file
IFS=',' read -ra PLUGINS <<< "$KYBER_ENABLED_PLUGINS"
for PLUGIN in "${PLUGINS[@]}"; do
  # Reject plugin names containing path separators or the bare '..' component to prevent path traversal
  if [[ "$PLUGIN" == */* ]] || [[ "$PLUGIN" == ".." ]]; then
    echo "Skipping invalid plugin name: '$PLUGIN' (must not contain '/' or be '..')"
    continue
  fi
  PLUGIN_DIR="$WORKING_DIR/$PLUGIN"
  if [ -d "$PLUGIN_DIR" ] && [ -f "$PLUGIN_DIR/plugin.json" ]; then
    # README and globals (editor type hints) aren't used by the server
    (cd "$PLUGIN_DIR" && zip -qr "$WORKING_DIR/$PLUGIN.kbplugin" . -x README.md globals.lua) || exit 1
    echo "Created $WORKING_DIR/$PLUGIN.kbplugin"
  else
    echo "Skipping $PLUGIN_DIR, no plugin.json found or directory does not exist."
  fi
done