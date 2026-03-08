#!/bin/bash

# This script will go through all directories relative to its location.
# It will zip the contents of the each directory and name the zip file 'DIRNAME.kbplugin'.
# kbplugin is for Kyber Star Wars Battlefront 2 server.

# Get the directory of the script
WORKING_DIR="$(pwd)"

# Check if the directory we're in has a plugins directory then update WORKING_DIR to that
if [ -d "$WORKING_DIR/plugins" ]; then
  WORKING_DIR="$WORKING_DIR/plugins"
fi

# Loop through all directories in the working directory
# Verify their is a plugin.json file in that directory
for dir in "$WORKING_DIR"/*/; do
  if [ -f "$dir/plugin.json" ]; then
    # Get the name of the directory
    DIR_NAME=$(basename "$dir")
    # Create a zip file with the name of the directory and .kbplugin extension
    # Remove existing file then create a fresh zip
    rm -f "$WORKING_DIR/$DIR_NAME.kbplugin"
    (cd "$dir" && zip -r "$WORKING_DIR/$DIR_NAME.kbplugin" .)
    echo "Created $WORKING_DIR/$DIR_NAME.kbplugin"
  else
    echo "Skipping $dir, no plugin.json found."
  fi
done