Config = {
    -- Percentage of bots to max players. Too many bots can be annoying.
    botDensity = tonumber(os.getenv("KYBER_PLUGIN_BOT_DENSITY")) or 0.8,
    -- In case you want to allow any gamemode
    useWhitelistGamemodes = os.getenv("KYBER_PLUGIN_USE_WHITELIST_GAMEMODES") == "true" or true,
    -- Will use the plugin shuffler rather than Kyber's default one.
    -- This is beneficial as we add additional logic for low player counts.
    enableShuffler = os.getenv("KYBER_PLUGIN_ENABLE_SHUFFLER") == "true" or true,
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
