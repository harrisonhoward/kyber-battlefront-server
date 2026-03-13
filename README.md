# kyber-battlefront-server

This is my the setup required for my personal dedicated Kyber Battlefront server.\
This repository is to assist others in setting up their own server.

## Server Information

- **Server Name**: Conquest - All Maps - 24/7
- **Region**: Sydney (OCE)
- **OS**: Debian GNU/Linux 13 (trixie)
- **CPU**: Intel Core i7-7700K @ 4.20GHz
- **Memory**: 16 GB DDR4 @ 2400 MHz

## Start Server Flags

This is a list of supported flags for the `start_battlefront.sh` script.

- `--server-name`: This allows you to override the server name specified in the `.env` file. This is useful if you want to have multiple servers running with different names.
- `--mode` (default: `conquest`): This allows you to specify the game mode to run.
    - Supported modes (Can be comma separated to combine the modes):
        - `conquest` (Conquest)
        - `galactic` (Galactic Assault)

## Installation

_I installed Debian from Windows Server 2025 Standard (which hosts my other servers)_

### Installing WSL 2

1. Open PowerShell as Administrator and run the following command to enable WSL:

    ```powershell
    wsl --install
    ```

2. Install the Debian distribution:

    ```powershell
    wsl --install -d Debian
    ```

3. (If not already) open the Debian distro and set up your username and password.

### Getting your Kyber and EA tokens

_This needs to be done from a GUI environment, this example is based on Windows_

1. Install the CLI tool from [Kyber Docs](https://docs.kyber.gg/g/hosting/dedicated-servers/prereq)
2. Unzip the contents of the location to your users bin folder (e.g. `C:\Users\Username\bin\kyber_cli`)
3. Update your users PATH variable to include this location (e.g. `C:\Users\Username\bin\kyber_cli`)
4. Open a new terminal and run the following commands (follow any required steps), taking note of the tokens for later:

    ```powershell
    kyber_cli get_token
    kyber_cli get_ea_token
    ```

### Installing Docker

Follow the instructions depending on the distro you chose [Kyber Docs](https://docs.kyber.gg/g/hosting/dedicated-servers/setup-linux)

### Setting up kyber_cli in Linux

1. Install the CLI tool from [Kyber Docs](https://docs.kyber.gg/g/hosting/dedicated-servers/prereq)
2. Unzip the contents of the location to your users bin folder (e.g. `~/bin/kyber_cli`)
3. Update your users PATH variable to include this location (e.g. `~/bin/kyber_cli`) (this can be in `~/.bashrc` or `~/.zshrc` depending on your shell)
4. Open a new terminal and verify the installation by running:

    ```bash
    kyber_cli help
    ```

### Setting up the server

1. Install and setup [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
2. Clone this repo into your Debian environment (e.g. `~/battlefront`)
3. Download Star Wars Battlefront II Game and place into the `install` folder (e.g. `~/battlefront/install`)

    ```bash
    kyber_cli download_game -p ~/battlefront/install -t <your_ea_token>
    ```

4. Create a `.env` file using the `.env.example` file as a template and fill in the required values (e.g. `~/battlefront/.env`)
5. Run the `start_server.sh` script to start the server:

    ```bash
    cd ~/battlefront
    ./start_server.sh
    ```

## Mods

You may add any mods to the server you want. You will need to add a `mods` folder and update `.env`.\
Below is how to get the mods used by the Official Kyber servers.

1. Open the Kyber Launcher
2. Select one of the "Official" servers
3. Click the "Download Mods" button situated in the right panel
4. Once downloaded go to the "Mods" section of the launcher
5. Create a new collection with the Battlefront Plus mod in it
6. Open the collection and click the action "Export Collection Tar"
7. Extract the contents of the tar file into the `mods` folder you created (e.g. `~/battlefront/mods`)
8. Update your `.env` to specify `KYBER_MOD_FOLDER_SOURCE` (Where it is ony our server) and `KYBER_MOD_FOLDER` (Where to put it on the Docker container)
