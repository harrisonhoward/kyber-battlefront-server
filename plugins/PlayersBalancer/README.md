# PlayersBalancer

This plugins automatically balances, shuffles players and fills empty slots with bots.\
This took a huge inspiration from [BotsBalancer Plugin Example](https://github.com/ArmchairDevelopers/PluginExamples/tree/main/BotBalancer).

## Configuration

You can configure the plugin by setting the following environment variables in your `.env` file:

```env
# PlayersBalancer plugin settings
KYBER_PLUGIN_BOT_DENSITY="0.8" # A value between 0 and 1 that determines how many bots to add to fill empty slots. Default is 0.8.
KYBER_PLUGIN_USE_WHITELIST_GAMEMODES="true" # If set to "true", the plugin will only balance players in gamemodes that are whitelisted. Default is "true".
KYBER_PLUGIN_ENABLE_SHUFFLER="true" # If set to "true", the plugin will shuffle players between teams to balance them. Default is "true".
```
