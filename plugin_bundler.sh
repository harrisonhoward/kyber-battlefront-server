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

# Bundles are shared by every instance, so each one is written to a temporary
# file and moved into place. A starting server never sees a missing bundle.
IFS=',' read -ra PLUGINS <<< "$KYBER_ENABLED_PLUGINS"
BUNDLED=()
for PLUGIN in "${PLUGINS[@]}"; do
  # Reject plugin names containing path separators or the bare '..' component to prevent path traversal
  if [[ "$PLUGIN" == */* ]] || [[ "$PLUGIN" == ".." ]]; then
    echo "Skipping invalid plugin name: '$PLUGIN' (must not contain '/' or be '..')"
    continue
  fi
  PLUGIN_DIR="$WORKING_DIR/$PLUGIN"
  if [ -d "$PLUGIN_DIR" ] && [ -f "$PLUGIN_DIR/plugin.json" ]; then
    # README and globals (editor type hints) aren't used by the server
    BUNDLE="$WORKING_DIR/$PLUGIN.kbplugin"
    rm -f "$BUNDLE.tmp"
    (cd "$PLUGIN_DIR" && zip -qr "$BUNDLE.tmp" . -x README.md globals.lua) || { rm -f "$BUNDLE.tmp"; exit 1; }
    mv -f "$BUNDLE.tmp" "$BUNDLE"
    BUNDLED+=("$BUNDLE")
    echo "Created $BUNDLE"
  else
    echo "Skipping $PLUGIN_DIR, no plugin.json found or directory does not exist."
  fi
done

# Remove bundles for plugins that are no longer enabled
for BUNDLE in "$WORKING_DIR"/*.kbplugin; do
  [ -f "$BUNDLE" ] || continue
  for ENABLED in "${BUNDLED[@]}"; do
    [ "$BUNDLE" = "$ENABLED" ] && continue 2
  done
  rm -f "$BUNDLE"
  echo "Removed $BUNDLE"
done
