local Config = require "config"
local TeamService = require "TeamService"

-- Console commands for changing bot settings on the fly, e.g. "PlayersBalancer.BotDifficulty easy".
-- They can be entered from the server console in the KYBER Launcher.
-- Changes last until the server restarts, the env vars set them again on start.

---@param args string|nil
---@return string
local function trim(args)
    return ((args or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

---@class CommandService
---@field BotDensity fun(self: CommandService, args: string)
---@field BotDifficulty fun(self: CommandService, args: string)
---@field BotHeroChance fun(self: CommandService, args: string)
---@field BotHeroPlayerLimit fun(self: CommandService, args: string)
---@field Register fun(self: CommandService) -- Registers the PlayersBalancer console commands
CommandService = {

    BotDensity = function(self, args)
        local value = trim(args)
        if value == "" then
            print(string.format("Bot density is %.2f", Config.botDensity))
            return
        end

        local density = Config.ParseBotDensity(value)
        if density == nil then
            print("Bot density must be between 0 and 1.")
            return
        end

        Config.botDensity = density
        TeamService:BalanceBots()
        Console.Execute(string.format("Kyber.Broadcast **KYBER:** Bot backfill capacity set to %.0f%%.", density * 100))
    end,

    BotDifficulty = function(self, args)
        local value = trim(args)
        if value == "" then
            print(string.format("Bot difficulty is %s", Config.botDifficulty))
            return
        end

        local difficulty = Config.ParseBotDifficulty(value)
        if difficulty == nil then
            print("Bot difficulty must be one of: easy, medium, hard, knight, master.")
            return
        end

        Config.botDifficulty = difficulty
        TeamService:ApplyBotSettings()
        Console.Execute(string.format("Kyber.Broadcast **KYBER:** Bot difficulty set to %s.", difficulty))
    end,

    BotHeroChance = function(self, args)
        local value = trim(args)
        if value == "" then
            print(string.format("Bot hero chance is %.2f", Config.botHeroChance))
            return
        end

        local chance = Config.ParseBotHeroChance(value)
        if chance == nil then
            print("Bot hero chance must be between 0 and 1.")
            return
        end

        Config.botHeroChance = chance
        TeamService:ApplyBotSettings()
        print(string.format("Bot hero chance set to %.2f", chance))
    end,

    BotHeroPlayerLimit = function(self, args)
        local value = trim(args)
        if value == "" then
            print(string.format("Bot hero player limit is %d", Config.botHeroPlayerLimit))
            return
        end

        local limit = Config.ParseBotHeroPlayerLimit(value)
        if limit == nil then
            print("Bot hero player limit must be a whole number of 0 or more.")
            return
        end

        Config.botHeroPlayerLimit = limit
        TeamService:ApplyBotSettings()
        print(string.format("Bot hero player limit set to %d", limit))
    end,

    Register = function(self)
        Console.Register("PlayersBalancer", "BotDensity",
            "Sets how full (0 to 1) bots fill the server. No value prints the current one.",
            self, self.BotDensity)
        Console.Register("PlayersBalancer", "BotDifficulty",
            "Sets the bot difficulty: easy, medium, hard, knight or master. No value prints the current one.",
            self, self.BotDifficulty)
        Console.Register("PlayersBalancer", "BotHeroChance",
            "Sets the chance (0 to 1) a bot picks a hero it can afford. No value prints the current one.",
            self, self.BotHeroChance)
        Console.Register("PlayersBalancer", "BotHeroPlayerLimit",
            "Sets how many players stop bots picking heroes, 0 disables it. No value prints the current one.",
            self, self.BotHeroPlayerLimit)
    end,
}

return CommandService
