# PlayersBalancer

This plugins automatically balances, shuffles players and fills empty slots with bots.\
This took a huge inspiration from [BotsBalancer Plugin Example](https://github.com/ArmchairDevelopers/PluginExamples/tree/main/BotBalancer).

## Supported Channel

`stable`

## Configuration

You can configure the plugin by setting the following environment variables in your `.env` file:

```env
# PlayersBalancer plugin settings
KYBER_PLUGIN_BOT_DENSITY="0.9" # A value between 0 and 1 that determines how many bots to add to fill empty slots. Default is 0.9.
KYBER_PLUGIN_USE_WHITELIST_GAMEMODES="true" # If set to "true", the plugin will only balance players in gamemodes that are whitelisted. Default is "true".
KYBER_PLUGIN_ENABLE_SHUFFLER="true" # If set to "true", the plugin will shuffle players between teams to balance them. Default is "true".
KYBER_PLUGIN_USE_BUILTIN_SHUFFLER="true" # If set to "true", shuffling uses Kyber's built-in shuffler (keeps parties/squads together) when there are more than 2 players; at 2 or fewer the plugin swaps teams instead, as Kyber's shuffler often leaves them unchanged. If "false", the plugin's own shuffler is always used. Only applies when KYBER_PLUGIN_ENABLE_SHUFFLER is "true". Default is "true".
KYBER_PLUGIN_ENABLE_AFK_KICK="true" # If set to "true", players are kicked after 5 minutes of no interactivity. If "false", AFK kicking is disabled (overrides the in-game setting). Default is "true".
```
