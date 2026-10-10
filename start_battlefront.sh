#!/bin/bash

source ./.env

# Print usage information
usage() {
  echo "Usage: $0 [--mode MODE] [--eras ERAS] [--server-name NAME] [--unschedule]"
  echo
  echo "Options:"
  echo "  --mode MODE           Game mode to use (default: conquest)"
  echo "  --eras ERAS           Eras to include: prequel,original,sequel,all (default: all)"
  echo "  --server-name NAME    Server name to use"
  echo "  --unschedule          Remove the cron restart schedule and exit"
}

# Flags processing
KYBER_SERVER_MODES="${KYBER_SERVER_MODES:-conquest}"
KYBER_SERVER_ERAS="${KYBER_SERVER_ERAS:-all}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --unschedule)
      CRON_MARKER="# kyber-battlefront restart"
      (crontab -l 2>/dev/null | grep -v "$CRON_MARKER") | crontab - 2>/dev/null || true
      echo "Cron restart schedule removed."
      exit 0
      ;;
    --mode)
      if [ $# -lt 2 ] || [ -z "$2" ]; then
        echo "Error: --mode requires a non-empty argument."
        usage
        exit 1
      fi
      KYBER_SERVER_MODES="$2"
      shift 2
      ;;
    --eras)
      if [ $# -lt 2 ] || [ -z "$2" ]; then
        echo "Error: --eras requires a non-empty argument."
        usage
        exit 1
      fi
      KYBER_SERVER_ERAS="$2"
      shift 2
      ;;
    --server-name)
      if [ $# -lt 2 ] || [ -z "$2" ]; then
        echo "Error: --server-name requires a non-empty argument."
        usage
        exit 1
      fi
      KYBER_SERVER_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1"
      usage
      exit 1
      ;;
  esac
done


conquest_prequel_maps=(
    "Mode1;S6_2/Geonosis_02/Levels/Geonosis_02/Geonosis_02"
    "Mode1;S7_1/Levels/Kamino_03/Kamino_03"
    "Mode1;S7_2/Levels/Naboo_03/Naboo_03"
    "Mode1;S7/Levels/Kashyyyk_02/Kashyyyk_02"
    "Mode1;S8/Felucia/Levels/MP/Felucia_01/Felucia_01"
)

conquest_original_maps=(
    "Mode1;S9_3/Scarif/Levels/MP/Scarif_02/Scarif_02"
    "Mode1;S9_3/Tatooine_02/Tatooine_02"
    "Mode1;Levels/MP/Yavin_01/Yavin_01"
    "Mode1;S9_3/Hoth_02/Hoth_02"
    "Mode1;Levels/MP/DeathStar02_01/DeathStar02_01"
)

conquest_sequel_maps=(
    "Mode1;S9/Jakku_02/Jakku_02"
    "Mode1;S9/Takodana_02/Takodana_02"
    "Mode1;S9/Paintball/Levels/MP/Paintball_01/Paintball_01"
)

galactic_prequel_maps=(
    "PlanetaryBattles;S5_1/Levels/MP/Geonosis_01/Geonosis_01"
    "PlanetaryBattles;Levels/MP/Kamino_01/Kamino_01"
    "PlanetaryBattles;Levels/MP/Naboo_01/Naboo_01"
    "PlanetaryBattles;Levels/MP/Kashyyyk_01/Kashyyyk_01"
)

galactic_original_maps=(
    "PlanetaryBattles;Levels/MP/Tatooine_01/Tatooine_01"
    "PlanetaryBattles;Levels/MP/Yavin_01/Yavin_01"
    "PlanetaryBattles;Levels/MP/Hoth_01/Hoth_01"
    "PlanetaryBattles;Levels/MP/Endor_01/Endor_01"
    "PlanetaryBattles;Levels/MP/DeathStar02_01/DeathStar02_01"
)

galactic_sequel_maps=(
    "PlanetaryBattles;Levels/MP/Jakku_01/Jakku_01"
    "PlanetaryBattles;Levels/MP/Takodana_01/Takodana_01"
    "PlanetaryBattles;Levels/MP/StarKiller_01/StarKiller_01"
    "PlanetaryBattles;S1/Levels/Crait_01/Crait_01"
)


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


trim_token() {
  local token="$1"
  token="${token#"${token%%[![:space:]]*}"}"
  token="${token%"${token##*[![:space:]]}"}"
  printf "%s" "$token"
}

append_maps_for_mode_and_era() {
  local mode="$1"
  local era="$2"

  case "$mode:$era" in
    conquest:prequel)
      maps+=("${conquest_prequel_maps[@]}")
      ;;
    conquest:original)
      maps+=("${conquest_original_maps[@]}")
      ;;
    conquest:sequel)
      maps+=("${conquest_sequel_maps[@]}")
      ;;
    galactic:prequel)
      maps+=("${galactic_prequel_maps[@]}")
      ;;
    galactic:original)
      maps+=("${galactic_original_maps[@]}")
      ;;
    galactic:sequel)
      maps+=("${galactic_sequel_maps[@]}")
      ;;
  esac
}

IFS=',' read -ra raw_modes <<< "$KYBER_SERVER_MODES"
IFS=',' read -ra raw_eras <<< "$KYBER_SERVER_ERAS"

modes=()
for raw_mode in "${raw_modes[@]}"; do
  mode=$(trim_token "$raw_mode")
  if [ -z "$mode" ]; then
    continue
  fi

  case "$mode" in
    conquest|galactic)
      modes+=("$mode")
      ;;
    *)
      echo "Unknown mode: $mode. Supported modes: conquest, galactic"
      exit 1
      ;;
  esac
done

if [ ${#modes[@]} -eq 0 ]; then
  echo "Error: no valid modes provided."
  exit 1
fi

eras=()
expand_all_eras=false
for raw_era in "${raw_eras[@]}"; do
  era=$(trim_token "$raw_era")
  if [ -z "$era" ]; then
    continue
  fi

  case "$era" in
    prequel|original|sequel)
      eras+=("$era")
      ;;
    all)
      expand_all_eras=true
      ;;
    *)
      echo "Unknown era: $era. Supported eras: prequel, original, sequel, all"
      exit 1
      ;;
  esac
done

if [ "$expand_all_eras" = true ]; then
  eras=(prequel original sequel)
fi

if [ ${#eras[@]} -eq 0 ]; then
  echo "Error: no valid eras provided."
  exit 1
fi

maps=()
for m in "${modes[@]}"; do
  for e in "${eras[@]}"; do
    append_maps_for_mode_and_era "$m" "$e"
  done
done

# Avoid duplicate entries when overlapping selections are provided.
deduped_maps=()
while IFS= read -r map_line; do
  deduped_maps+=("$map_line")
done < <(printf "%s\n" "${maps[@]}" | awk '!seen[$0]++')
maps=("${deduped_maps[@]}")

if [ ${#maps[@]} -eq 0 ]; then
  echo "Error: no maps found for selected modes and eras."
  exit 1
fi

# Shuffle the maps then base 64 encode the map rotation string
map_rotation=$(printf "%s\n" "${maps[@]}" | shuf | base64 -w 0)

docker_args=(
  --name kyber-battlefront
  --restart unless-stopped
  -dt
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
[ -n "$KYBER_PLUGIN_USE_BUILTIN_SHUFFLER" ]    && docker_args+=(-e "KYBER_PLUGIN_USE_BUILTIN_SHUFFLER=$KYBER_PLUGIN_USE_BUILTIN_SHUFFLER")
[ -n "$KYBER_PLUGIN_ENABLE_AFK_KICK" ]         && docker_args+=(-e "KYBER_PLUGIN_ENABLE_AFK_KICK=$KYBER_PLUGIN_ENABLE_AFK_KICK")

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

# Stop and remove any existing container (running or stopped) so the name is free
docker rm -f kyber-battlefront 2>/dev/null || true

docker run \
  "${docker_args[@]}" \
  ghcr.io/armchairdevelopers/kyber-server:latest || { echo "Error: docker run failed. Cron not updated."; exit 1; }

# Install or remove a cron job for scheduled daily restarts.
# Set KYBER_RESTART_SCHEDULE in .env to a cron expression (e.g. "0 4 * * *") to enable.
# Leave it unset or empty to remove any existing schedule.
SCRIPT_DIR=$(cd "$(dirname "$(realpath "$0")")" && pwd)
SCRIPT_PATH="$SCRIPT_DIR/$(basename "$0")"
CRON_MARKER="# kyber-battlefront restart"
if [ -n "$KYBER_RESTART_SCHEDULE" ]; then
  # Validate: must be exactly 5 whitespace-separated fields, no newlines
  if [[ "$KYBER_RESTART_SCHEDULE" =~ $'\n' ]] || [[ ! "$KYBER_RESTART_SCHEDULE" =~ ^[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+$ ]]; then
    echo "Error: KYBER_RESTART_SCHEDULE must be a valid 5-field cron expression."
    exit 1
  fi
  CRON_CMD="$KYBER_RESTART_SCHEDULE /bin/bash -c 'cd \"$SCRIPT_DIR\" && \"$SCRIPT_PATH\"' $CRON_MARKER"
  (crontab -l 2>/dev/null | grep -v "$CRON_MARKER"; echo "$CRON_CMD") | crontab -
  echo "Cron restart scheduled: $KYBER_RESTART_SCHEDULE"
else
  (crontab -l 2>/dev/null | grep -v "$CRON_MARKER") | crontab - 2>/dev/null || true
fi

docker logs -f kyber-battlefront
