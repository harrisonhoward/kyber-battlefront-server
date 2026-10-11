# Adding game modes

Out of the box, [`start_battlefront.sh`](../start_battlefront.sh) builds map rotations for Conquest (`conquest`) and Galactic Assault (`galactic`). This guide covers adding another mode so it can be selected with `KYBER_SERVER_MODES` and combined with eras like the built-in ones.

The examples add Heroes vs Villains as `hvv`. Replace the mode name, mode ID and level paths with the ones for your mode.

## How the rotation is built

Each rotation entry is a `<ModeId>;<LevelPath>` string, e.g.:

```text
Mode1;S9_3/Hoth_02/Hoth_02                          # Conquest on Hoth
PlanetaryBattles;Levels/MP/Hoth_01/Hoth_01          # Galactic Assault on Hoth
```

The script keeps one list per mode and era (`<mode>_<era>_maps`), collects the lists matching `KYBER_SERVER_MODES` and `KYBER_SERVER_ERAS`, removes duplicates, shuffles them and passes the result to the server as `KYBER_MAP_ROTATION`.

You will need the mode ID and the level path of every map you want. The easiest way to get them is to export a rotation from the Kyber Launcher:

1. Click **Host**.
2. Add the maps you want from each mode to the map rotation.
3. Export the rotation, choosing the **base64** type, and copy it to the clipboard or save it to a file.
4. Decode it to get the entries, ready to paste into the script:

    ```bash
    echo '<exported base64>' | base64 -d
    ```

The base64 export is the same format the server reads from `KYBER_MAP_ROTATION`, so no conversion is needed. The **json** export holds the same `mode` and `map` values if you prefer to read those. The full list of modes and maps is in the launcher's source, in [`modes.dart`](https://github.com/ArmchairDevelopers/Kyber/blob/HEAD/Launcher/lib/features/kyber/models/modes.dart) and [`maps.dart`](https://github.com/ArmchairDevelopers/Kyber/blob/HEAD/Launcher/lib/features/kyber/models/maps.dart). The same planet often uses a different level per mode (e.g. `Hoth_02` for Conquest and `Hoth_01` for Galactic Assault), so check each one rather than copying the paths from another mode.

## 1. Add the map lists

In `start_battlefront.sh`, add a list per era next to the existing ones:

```bash
hvv_prequel_maps=(
    "HeroesVersusVillains;<level path>"
)

hvv_original_maps=(
    "HeroesVersusVillains;<level path>"
)

hvv_sequel_maps=(
    "HeroesVersusVillains;<level path>"
)
```

If eras don't make sense for your mode, put every map in each era's list. Duplicates are removed when eras are combined, so `all` still plays each map once.

## 2. Map the lists to the mode and era

Add a case per era to `append_maps_for_mode_and_era`:

```bash
    hvv:prequel)
      maps+=("${hvv_prequel_maps[@]}")
      ;;
    hvv:original)
      maps+=("${hvv_original_maps[@]}")
      ;;
    hvv:sequel)
      maps+=("${hvv_sequel_maps[@]}")
      ;;
```

## 3. Accept the mode name

Add the mode to the validation in the `KYBER_SERVER_MODES` loop, and to its error message:

```bash
  case "$mode" in
    conquest|galactic|hvv)
      modes+=("$mode")
      ;;
    ...
    *)
      echo "Unknown mode: $mode. Supported modes: conquest, galactic, hvv, all"
      exit 1
      ;;
  esac
```

Decide whether `all` should include it. If so, add it to the expansion:

```bash
if [ "$expand_all_modes" = true ]; then
  modes=(conquest galactic hvv)
fi
```

## 4. Check the plugins

**MapShuffler** needs no changes. It works with any entries in the rotation.

**PlayersBalancer** only balances teams and adds bots in the game modes listed in `whitelistedGameModes` in [`plugins/PlayersBalancer/server/ServerService.lua`](../plugins/PlayersBalancer/server/ServerService.lua). If your mode ID isn't listed, either:

- add it to the list, if the mode has two teams and bots make sense in it, or
- leave it out, and the balancer skips that mode (logging `Game mode '<id>' is not whitelisted`).

`KYBER_PLUGIN_USE_WHITELIST_GAMEMODES="false"` turns the whitelist off entirely, so the balancer runs in every mode.
