local Config = require "config"

-- The gamemodes the balancer should be active for
local whitelistedGameModes = {
    "Mode1",
    "PlanetaryBattles",
    "IOISupremacyUnrestricted",
    "IOIGANoFun"
}

---@alias GameMode
---| { name: string, maxPlayers: number }

---@alias InformationAsset
---| { typeInfo: { name: string }, gameModeId: string, aurebeshGameModeName: string, numberOfPlayers: number }

---@class ServerService
---@field serverInitialised boolean -- Track the server has initialised
---@field gameModes table<string, GameMode>
---@field activeGameMode GameMode|nil
---@field AddGameMode fun(self: ServerService, instance: InformationAsset)
---@field IsGameModeWhitelisted fun(self: ServerService, gameModeId: string): boolean
---@field GetTeamCounts fun(self: ServerService): { team1: number, team2: number }
ServerService = {
    serverInitialised = false,
    gameModes = {},
    activeGameMode = nil,

    AddGameMode = function(self, instance)
        if instance.typeInfo.name ~= "GameModeInformationAsset" then
            return
        end

        self.gameModes[instance.gameModeId] = {
            name = instance.aurebeshGameModeName,
            maxPlayers = instance.numberOfPlayers,
        }
        -- Log the registration
        print(string.format("Registered gamemode: %s with max players: %d",
            instance.aurebeshGameModeName,
            instance.numberOfPlayers))
    end,

    IsGameModeWhitelisted = function(self, gameModeId)
        -- Skip if the config indicates that we should ignore this operation
        if Config.useWhitelistGamemodes == false then
            return true
        end

        for _, whitelistedGameMode in ipairs(whitelistedGameModes) do
            if whitelistedGameMode == gameModeId then
                return true
            end
        end

        return false
    end,
}

return ServerService;
