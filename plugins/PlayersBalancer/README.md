# PlayersBalancer

This plugins automatically balances, shuffles players and fills empty slots with bots.\
Players who leave and rejoin during the same level go back to their old team, unless that would put it more than two players ahead, in which case they are balanced as normal. Their score, kills, assists, deaths and battlepoints are restored when they rejoin. All of this is forgotten when the level completes.\
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
KYBER_PLUGIN_BOT_DIFFICULTY="knight" # Bot aim difficulty, matching the launcher titles: "easy", "medium", "hard", "knight" or "master". Default is "knight".
KYBER_PLUGIN_BOT_HERO_CHANCE="0.25" # A value between 0 and 1 for the chance a bot picks a hero when it can afford one. 0 stops bots picking heroes. Default is 0.25.
KYBER_PLUGIN_BOT_HERO_PLAYER_LIMIT="8" # Bots stop picking heroes once this many players (not bots) are online. 0 disables the limit, so bots can always pick heroes. Default is 8.
```

Bot difficulty sets the bots' aim noise scale (lower is more accurate):

| Difficulty | Aim noise scale |
| ---------- | --------------- |
| `master`   | 0               |
| `knight`   | 3               |
| `hard`     | 6               |
| `medium`   | 9               |
| `easy`     | 12              |
