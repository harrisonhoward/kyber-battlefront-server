#!/bin/bash

source ./.env


# This script will go through all directories relative to its location.
# It will zip the contents of the each directory and name the zip file 'DIRNAME.kbplugin'.
# kbplugin is for Kyber Star Wars Battlefront 2 server.

# Get the directory of the script
WORKING_DIR="$(pwd)"

# Check if the directory we're in has a plugins directory then update WORKING_DIR to that
if [ -d "$WORKING_DIR/plugins" ]; then
  WORKING_DIR="$WORKING_DIR/plugins"
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
  PLUGIN_DIR="$WORKING_DIR/$PLUGIN"
  if [ -d "$PLUGIN_DIR" ] && [ -f "$PLUGIN_DIR/plugin.json" ]; then
    (cd "$PLUGIN_DIR" && zip -r "$WORKING_DIR/$PLUGIN.kbplugin" .)
    echo "Created $WORKING_DIR/$PLUGIN.kbplugin"
  else
    echo "Skipping $PLUGIN_DIR, no plugin.json found or directory does not exist."
  fi
done