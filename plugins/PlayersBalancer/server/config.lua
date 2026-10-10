Config = {
    -- Percentage of bots to max players. Too many bots can be annoying.
    botDensity = tonumber(os.getenv("KYBER_PLUGIN_BOT_DENSITY")) or 0.9,
    -- In case you want to allow any gamemode
    useWhitelistGamemodes = (os.getenv("KYBER_PLUGIN_USE_WHITELIST_GAMEMODES") or "true") == "true",
    -- Will use the plugin shuffler rather than Kyber's default one.
    -- This is beneficial as we add additional logic for low player counts.
    enableShuffler = (os.getenv("KYBER_PLUGIN_ENABLE_SHUFFLER") or "true") == "true",
    -- When shuffling is enabled, use Kyber's built-in shuffler instead of the plugin one.
    -- Kyber's shuffler keeps parties/squads together.
    useBuiltInShuffler = (os.getenv("KYBER_PLUGIN_USE_BUILTIN_SHUFFLER") or "true") == "true",
    -- Kick players after 5 minutes of no interactivity
    enableAfkKick = (os.getenv("KYBER_PLUGIN_ENABLE_AFK_KICK") or "true") == "true",
}

-- Validation
if Config.botDensity < 0 or Config.botDensity > 1 then
    error("Bot density must be between 0 and 1.")
end
if (os.getenv("KYBER_MODULE_CHANNEL") or "stable") ~= "stable" then
    error(
        "PlayersBalancer plugin is only compatible with the stable channel. Either modify the plugin yourself, or change back to the stable channel.")
end

return Config
