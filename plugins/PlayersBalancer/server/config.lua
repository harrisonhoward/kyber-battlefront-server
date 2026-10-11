-- Bot aim noise scale for each launcher difficulty, lower is more accurate
local botDifficultyAimNoise = {
    master = 0,
    knight = 3,
    hard = 6,
    medium = 9,
    easy = 12,
}

-- Empty values are treated as unset so the default applies
local function optionalEnv(name)
    local value = os.getenv(name)
    if value == "" then
        return nil
    end
    return value
end

-- Parsers shared by the env vars and the console commands, nil when invalid
local function parseBotDifficulty(value)
    local difficulty = string.lower(value)
    if botDifficultyAimNoise[difficulty] == nil then
        return nil
    end
    return difficulty
end

local function parseBotHeroChance(value)
    local chance = tonumber(value)
    if chance == nil or chance < 0 or chance > 1 then
        return nil
    end
    return chance
end

local function parseBotHeroPlayerLimit(value)
    local limit = tonumber(value)
    if limit == nil or limit < 0 or limit % 1 ~= 0 then
        return nil
    end
    return math.tointeger(limit)
end

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
    -- Bot difficulty by launcher name, see botDifficultyAimNoise
    botDifficulty = parseBotDifficulty(optionalEnv("KYBER_PLUGIN_BOT_DIFFICULTY") or "hard"),
    -- Chance a bot picks a hero when it can afford one
    botHeroChance = parseBotHeroChance(optionalEnv("KYBER_PLUGIN_BOT_HERO_CHANCE") or "0.25"),
    -- Bots stop taking heroes once this many players are online, 0 disables the limit
    botHeroPlayerLimit = parseBotHeroPlayerLimit(optionalEnv("KYBER_PLUGIN_BOT_HERO_PLAYER_LIMIT") or "8"),

    botDifficultyAimNoise = botDifficultyAimNoise,
    ParseBotDifficulty = parseBotDifficulty,
    ParseBotHeroChance = parseBotHeroChance,
    ParseBotHeroPlayerLimit = parseBotHeroPlayerLimit,
}

-- Validation
if Config.botDensity < 0 or Config.botDensity > 1 then
    error("Bot density must be between 0 and 1.")
end
if Config.botDifficulty == nil then
    error("Bot difficulty must be one of: easy, medium, hard, knight, master.")
end
if Config.botHeroChance == nil then
    error("Bot hero chance must be between 0 and 1.")
end
if Config.botHeroPlayerLimit == nil then
    error("Bot hero player limit must be a whole number of 0 or more.")
end
if (os.getenv("KYBER_MODULE_CHANNEL") or "stable") ~= "stable" then
    error(
        "PlayersBalancer plugin is only compatible with the stable channel. Either modify the plugin yourself, or change back to the stable channel.")
end

return Config
