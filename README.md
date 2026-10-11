# kyber-battlefront-server

The setup for my personal dedicated [Kyber](https://kyber.gg) Star Wars Battlefront II server, shared so others can run their own.

- [`start_battlefront.sh`](start_battlefront.sh) runs the server in Docker
- Map rotations built from your chosen game modes and eras
- [Plugins](#plugins) for map shuffling and bot team balancing
- Optional scheduled restarts and [multiple instances](#multiple-instances)

> This is for self-hosting on your own Linux machine. If you just want a server without managing one, use the hosting built into the Kyber Launcher instead.

## Contents

- [kyber-battlefront-server](#kyber-battlefront-server)
  - [Contents](#contents)
  - [Requirements](#requirements)
  - [Setup](#setup)
    - [1. Linux environment (Windows only)](#1-linux-environment-windows-only)
    - [2. Docker](#2-docker)
    - [3. Kyber and EA tokens](#3-kyber-and-ea-tokens)
    - [4. Server](#4-server)
  - [Usage](#usage)
  - [Configuration](#configuration)
    - [Required](#required)
    - [Server](#server)
    - [Mods and plugins](#mods-and-plugins)
  - [Multiple instances](#multiple-instances)
  - [Mods](#mods)
  - [Plugins](#plugins)
  - [Troubleshooting](#troubleshooting)

## Requirements

- Linux host with Docker (runnable without `sudo`, which the restart schedule relies on). WSL 2 works.
- An EA account that owns Star Wars Battlefront II
- A Kyber account
- A desktop with a browser to get your tokens
- `git` and `zip`

## Setup

### 1. Linux environment (Windows only)

_I run Debian on WSL 2 from Windows Server 2025, which hosts my other servers. Skip this if your host already runs Linux._

```powershell
wsl --install
wsl --install -d Debian
```

### 2. Docker

Follow the [Kyber Linux setup guide](https://docs.kyber.gg/g/hosting/dedicated-servers/setup-linux) for your distro.

### 3. Kyber and EA tokens

_This needs a browser, so do it from your desktop._

1. Install `kyber_cli` from the [Kyber prerequisites page](https://docs.kyber.gg/g/hosting/dedicated-servers/prereq) and add it to your `PATH`.
2. Get your tokens and keep them for later:

    ```powershell
    kyber_cli get_token
    kyber_cli get_ea_token
    ```

### 4. Server

1. Install `kyber_cli` on the Linux host as well, and add it to your `PATH`.
2. Clone this repo and download the game into `install`:

    ```bash
    git clone https://github.com/harrisonhoward/kyber-battlefront-server.git ~/battlefront
    cd ~/battlefront
    kyber_cli download_game -p ~/battlefront/install -t <your_ea_token>
    ```

3. Create your `.env` from the example and fill in the [required values](#required):

    ```bash
    cp .env.example .env
    ```

    - Use absolute paths (`/home/you/...`). A quoted `~` isn't expanded, so Docker won't find the folder.
    - `KYBER_MOD_FOLDER` is set in the example. If you aren't using [mods](#mods), comment it out, otherwise the script requires `KYBER_MOD_FOLDER_SOURCE`.
    - Set `KYBER_SERVER_PLUGINS_SOURCE` to this repo's `plugins` folder, or comment out `KYBER_SERVER_PLUGINS_PATH` to run without plugins.

4. Start the server:

    ```bash
    ./start_battlefront.sh
    ```

    This pulls the latest Kyber image, bundles the plugins, (re)creates the container and follows its logs. `Ctrl+C` stops following the logs; the server keeps running.

## Usage

```bash
./start_battlefront.sh                 # start, or restart to apply .env changes and Kyber updates
docker logs -f kyber-battlefront       # follow logs
docker stop kyber-battlefront          # stop
./start_battlefront.sh --teardown      # remove the server
```

| Flag | Description |
| ---- | ----------- |
| `--instance <id>` | Runs the instance configured in `<id>.instance.env`. See [Multiple instances](#multiple-instances). |
| `--unschedule` | Removes the restart schedule and exits without touching the running container. Combine with `--instance` to only remove that instance's schedule. |
| `--teardown` | Removes the server and exits. With `--instance`, removes only that instance's container and restart schedule. Without it, removes every `kyber-battlefront` container, all of their restart schedules and the Kyber server images. Asks for confirmation when run from a terminal. Game files, mods and env files are not touched. |

## Configuration

Settings are set in `.env` (see [`.env.example`](.env.example)), or in an instance file when running [multiple instances](#multiple-instances).

### Required

| Setting | Description |
| ------- | ----------- |
| `EA_EMAIL`, `EA_PASSWORD` | EA account that owns the game. |
| `KYBER_TOKEN` | From `kyber_cli get_token`. |
| `KYBER_SERVER_NAME` | Name shown in the server browser (max 40 characters). |
| `KYBER_INSTALL_PATH` | Absolute path to the game install. |

### Server

| Setting | Default | Description |
| ------- | ------- | ----------- |
| `KYBER_SERVER_MODES` | `conquest` | Comma separated: `conquest`, `galactic` (Galactic Assault) or `all`. |
| `KYBER_SERVER_ERAS` | `all` | Comma separated: `prequel`, `original`, `sequel` or `all`. |
| `KYBER_SERVER_DESCRIPTION` | | Server browser description. |
| `KYBER_SERVER_PASSWORD` | | Password required to join. |
| `KYBER_SERVER_MAX_PLAYERS` | | Player limit. |
| `KYBER_RESTART_SCHEDULE` | | Cron expression for scheduled restarts, in the host's local time (e.g. `"0 4 * * *"`). Unset removes the schedule. |
| `KYBER_MODULE_CHANNEL` | | Kyber release channel. The plugins support `stable`. |
| `KYBER_LOG_LEVEL` | | Server log level, e.g. `info`. |

For example, `KYBER_SERVER_MODES="conquest,galactic"` with `KYBER_SERVER_ERAS="prequel,original"` runs both modes on prequel and original trilogy maps.

To run other game modes, see [Adding game modes](docs/adding-game-modes.md).

### Mods and plugins

| Setting | Description |
| ------- | ----------- |
| `KYBER_MOD_FOLDER_SOURCE` | Absolute path to the mods folder on the host. Required when `KYBER_MOD_FOLDER` is set. |
| `KYBER_MOD_FOLDER` | Mods path inside the container. |
| `KYBER_SERVER_PLUGINS_SOURCE` | Absolute path to this repo's `plugins` folder. Required when `KYBER_SERVER_PLUGINS_PATH` is set. |
| `KYBER_SERVER_PLUGINS_PATH` | Plugins path inside the container. |
| `KYBER_ENABLED_PLUGINS` | Comma separated plugins to load. Defaults to all of them. |
| `KYBER_PLUGIN_*` | Plugin settings, see each [plugin's README](#plugins). |

## Multiple instances

Multiple servers can run at the same time from the same install and account. Shared settings (credentials, install path, plugins) stay in `.env`, and each instance has its own `<id>.instance.env` file that overrides what differs, usually the name and eras.

Kyber limits how many servers one account can host at once, and this counts the main server (no `--instance`) too:

| Account | Max servers |
| ------- | ----------- |
| Everyone | 2 |
| Patreon | 4 |
| Verified host | 6 |

1. Copy [`example.instance.env`](example.instance.env) to e.g. `prequel.instance.env` and set its values.
2. Start it with `./start_battlefront.sh --instance prequel`.

Each instance runs in its own container (`kyber-battlefront-<id>`) with its own restart schedule. Running without `--instance` uses the `kyber-battlefront` container and `.env` alone. Plugins are shared between all instances, so set `KYBER_ENABLED_PLUGINS` in `.env`. Mods can differ per instance, see [Different mods per instance](#different-mods-per-instance). Stagger `KYBER_RESTART_SCHEDULE` between instances so they don't restart at once.

```bash
docker logs -f kyber-battlefront-prequel                  # follow an instance's logs
./start_battlefront.sh --instance prequel --unschedule    # remove its restart schedule
```

## Mods

Any mods can be used. To get the mods used by the official Kyber servers:

1. In the Kyber Launcher, select an "Official" server and click **Download Mods** in the right panel.
2. In the **Mods** section, create a collection with the Battlefront Plus mod.
3. Open the collection and choose **Export Collection Tar**.
4. Extract the tar into a `mods` folder (e.g. `~/battlefront/mods`).
5. Set `KYBER_MOD_FOLDER_SOURCE` to that folder and `KYBER_MOD_FOLDER` to where it should be mounted in the container (e.g. `/mnt/battlefront/mods`).

### Different mods per instance

Each [instance](#multiple-instances) can run its own mods, since `KYBER_MOD_FOLDER_SOURCE` can be overridden in its instance file.

1. Export each mod collection into its own folder under `mods` (ignored by git), e.g.:

    ```text
    ~/battlefront/mods/
    ├── bfplus/      # Battlefront Plus
    └── custom/      # another collection
    ```

2. Set the default in `.env`, used by the main server and any instance that doesn't override it:

    ```env
    KYBER_MOD_FOLDER_SOURCE="/home/you/battlefront/mods/bfplus"
    KYBER_MOD_FOLDER="/mnt/battlefront/mods"
    ```

3. Override it in the instance file, e.g. `custom.instance.env`:

    ```env
    KYBER_SERVER_NAME="My Custom Server"
    KYBER_MOD_FOLDER_SOURCE="/home/you/battlefront/mods/custom"
    ```

    To run an instance without mods, clear the container path instead:

    ```env
    KYBER_MOD_FOLDER=""
    ```

4. Start (or restart) each instance:

    ```bash
    ./start_battlefront.sh --instance custom
    ```

Restart the instance after changing its mod folder. Plugins are still shared between all instances.

## Plugins

Plugins in [`plugins`](plugins) are bundled into `.kbplugin` files each time the server starts.

| Plugin | Description |
| ------ | ----------- |
| [MapShuffler](plugins/MapShuffler/README.md) | Shuffles the map rotation each cycle, avoiding the same map twice in a row. |
| [PlayersBalancer](plugins/PlayersBalancer/README.md) | Balances teams, fills empty slots with bots and restores rejoining players' teams and scores. |

## Troubleshooting

| Error | Fix |
| ----- | --- |
| `Please set EA_EMAIL, EA_PASSWORD, KYBER_TOKEN, ...` | A required value is empty, or `.env` is missing from the script's folder. |
| `KYBER_MOD_FOLDER_SOURCE must be set if KYBER_MOD_FOLDER is set.` | Set the mods path, or comment out `KYBER_MOD_FOLDER`. |
| `KYBER_SERVER_PLUGINS_SOURCE must be set if KYBER_SERVER_PLUGINS_PATH is set.` | Set the plugins path, or comment out `KYBER_SERVER_PLUGINS_PATH`. |
| `zip is required to bundle plugins` | Install `zip`. |
| Server doesn't show in the browser | Check `docker logs -f kyber-battlefront`, that `KYBER_INSTALL_PATH` is absolute, and your credentials. |
