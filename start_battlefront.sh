#!/bin/bash

if [ ! -e ./.env ]; then
  touch ./.env
fi

# User must define these
if [ -z "$EA_EMAIL" ] || [ -z "$EA_PASSWORD" ] || [ -z "$KYBER_TOKEN" ] || [ -z "$KYBER_SERVER_NAME" ] || [ -z "$KYBER_INSTALL_PATH" ]; then
  echo "Please set EA_EMAIL, EA_PASSWORD, KYBER_TOKEN, KYBER_SERVER_NAME, and KYBER_INSTALL_PATH in the env file."
  exit 1
fi

# If KYBER_MOD_FOLDER set then so does KYBER_MOD_FOLDER_SOURCE
if [ -n "$KYBER_MOD_FOLDER" ] && [ -z "$KYBER_MOD_FOLDER_SOURCE" ]; then
  echo "KYBER_MOD_FOLDER_SOURCE must be set if KYBER_MOD_FOLDER is set."
  exit 1
fi

# If KYBER_SERVER_PLUGINS_PATH set then so does KYBER_SERVER_PLUGINS_SOURCE
if [ -n "$KYBER_SERVER_PLUGINS_PATH" ] && [ -z "$KYBER_SERVER_PLUGINS_SOURCE" ]; then
  echo "KYBER_SERVER_PLUGINS_SOURCE must be set if KYBER_SERVER_PLUGINS_PATH is set."
  exit 1
fi


maps=(
    "Mode1;S9/Paintball/Levels/MP/Paintball_01/Paintball_01"
    "Mode1;Levels/MP/DeathStar02_01/DeathStar02_01"
    "Mode1;S7_2/Levels/Naboo_03/Naboo_03"
    "Mode1;S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02"
    "Mode1;S7_1/Levels/Kamino_03/Kamino_03"
    "Mode1;S7/Levels/Kashyyyk_02/Kashyyyk_02"
    "Mode1;S9_3/Tatooine_02/Tatooine_02"
    "Mode1;Levels/MP/Yavin_01/Yavin_01"
    "Mode1;S9_3/Scarif/Levels/MP/Scarif_02/Scarif_02"
    "Mode1;S9/Jakku_02/Jakku_02"
    "Mode1;S9/Takodana_02/Takodana_02"
    "Mode1;S8/Felucia/Levels/MP/Felucia_01/Felucia_01"
    "Mode1;S9_3/Hoth_02/Hoth_02"
)

# Shuffle the maps then base 64 encode the map rotation string
map_rotation=$(printf "%s\n" "${maps[@]}" | shuf | base64 -w 0)

docker_args=(
  -e "MAXIMA_CREDENTIALS=$EA_EMAIL:$EA_PASSWORD"
  -e "KYBER_TOKEN=$KYBER_TOKEN"
  -e "KYBER_SERVER_NAME=$KYBER_SERVER_NAME"
  -e "KYBER_MAP_ROTATION=$map_rotation"
)

# Optional server settings
[ -n "$KYBER_SERVER_DESCRIPTION" ]  && docker_args+=(-e "KYBER_SERVER_DESCRIPTION=$KYBER_SERVER_DESCRIPTION")
[ -n "$KYBER_SERVER_PASSWORD" ]     && docker_args+=(-e "KYBER_SERVER_PASSWORD=$KYBER_SERVER_PASSWORD")
[ -n "$KYBER_SERVER_MAX_PLAYERS" ]  && docker_args+=(-e "KYBER_SERVER_MAX_PLAYERS=$KYBER_SERVER_MAX_PLAYERS")
[ -n "$KYBER_MODULE_CHANNEL" ]      && docker_args+=(-e "KYBER_MODULE_CHANNEL=$KYBER_MODULE_CHANNEL")
[ -n "$KYBER_LOG_LEVEL" ]           && docker_args+=(-e "KYBER_LOG_LEVEL=$KYBER_LOG_LEVEL")

# Optional plugin settings
[ -n "$KYBER_PLUGIN_BOT_DENSITY" ]             && docker_args+=(-e "KYBER_PLUGIN_BOT_DENSITY=$KYBER_PLUGIN_BOT_DENSITY")
[ -n "$KYBER_PLUGIN_USE_WHITELIST_GAMEMODES" ] && docker_args+=(-e "KYBER_PLUGIN_USE_WHITELIST_GAMEMODES=$KYBER_PLUGIN_USE_WHITELIST_GAMEMODES")
[ -n "$KYBER_PLUGIN_ENABLE_SHUFFLER" ]         && docker_args+=(-e "KYBER_PLUGIN_ENABLE_SHUFFLER=$KYBER_PLUGIN_ENABLE_SHUFFLER")

# Install path (required)
docker_args+=(-v "$KYBER_INSTALL_PATH:/mnt/battlefront")

# Mod folder (optional)
if [ -n "$KYBER_MOD_FOLDER" ]; then
  docker_args+=(
    -e "KYBER_MOD_FOLDER=$KYBER_MOD_FOLDER"
    -v "$KYBER_MOD_FOLDER_SOURCE:$KYBER_MOD_FOLDER"
  )
fi

# Server plugins (optional)
if [ -n "$KYBER_SERVER_PLUGINS_PATH" ]; then
  docker_args+=(
    -e "KYBER_SERVER_PLUGINS_PATH=$KYBER_SERVER_PLUGINS_PATH"
    -v "$KYBER_SERVER_PLUGINS_SOURCE:$KYBER_SERVER_PLUGINS_PATH"
  )
fi

# Run the plugins bundler
./plugin_bundler.sh

sudo docker run \
  "${docker_args[@]}" \
  -it ghcr.io/armchairdevelopers/kyber-server:latest
