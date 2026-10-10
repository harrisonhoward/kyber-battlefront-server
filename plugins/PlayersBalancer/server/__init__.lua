local Config = require "config"
local ServerService = require "ServerService"
local TeamService = require "TeamService"
local PlayerService = require "PlayerService"

local function init()
    print(
        string.format("Balancing bots for game mode '%s' with %d max players",
            ServerService.activeGameMode.name, ServerService.activeGameMode.maxPlayers)
    )
    Console.Execute(
        string.format("Kyber.Broadcast **KYBER:** Bot balancing enabled with %.0f%% backfill capacity.",
            Config.botDensity * 100)
    )

    -- Setup for Kyber team balancing
    local useBuiltInShuffler = Config.enableShuffler and Config.useBuiltInShuffler
    local kyberSettings = Console.GetSettings("Kyber")
    if kyberSettings ~= nil then
        kyberSettings.disableTeamBalancing = true
        kyberSettings.enableShuffleTeams = useBuiltInShuffler
    end
    local wsSettings = Console.GetSettings("Whiteshark")
    if wsSettings ~= nil then
        wsSettings.autoBalanceTeamsOnNeutral = false
        if Config.enableAfkKick then
            wsSettings.noInteractivityTimeoutTime = 60 * 5
        end
    end
    print("Disabled traditional team balancing in favour for PlayersBalancer's")

    -- Fall back to the plugin shuffler when Kyber's built-in one is disabled
    if Config.enableShuffler and not useBuiltInShuffler then
        TeamService:RandomiseTeams()
    end
    TeamService:BalanceBots()
end

EventManager.Listen("Server:Init", function()
    ServerService.serverInitialised = true
end)

-- Triggered by a game file that can contain vital gamemode information for us.
EventManager.Listen("ResourceManager:PartitionLoaded", function(_name, instance)
    ServerService:AddGameMode(instance)
end)

EventManager.Listen("Level:Loaded", function(_levelName, gameModeId)
    if ServerService.gameModes[gameModeId] == nil then
        print(
            string.format("Loaded into an unknown game mode with id '%s'", gameModeId)
        )
        TeamService:ResetBots()
        return
    end

    if not ServerService:IsGameModeWhitelisted(gameModeId) then
        print(
            string.format("Game mode '%s' is not whitelisted. Skipping bot balancing.", gameModeId)
        )
        TeamService:ResetBots()
        return
    end

    ServerService.activeGameMode = ServerService.gameModes[gameModeId]

    -- Only run on subsequent level loads (e.g. map changes)
    if ServerService.serverInitialised == true then
        init()
    end
end)

-- Cleanup from the previous level before the next one loads
EventManager.Listen("Level:Complete", function()
    TeamService:ResetBots()
end)

EventManager.Listen("ServerPlayer:Joined", function(player)
    if player == nil then
        print("ServerPlayer:Joined event triggered with nil player, skipping.")
        return
    end

    -- Balancer is not active for this game mode
    if ServerService.activeGameMode == nil then
        return
    end

    -- Exclude the joining player as they may already be assigned a default team
    PlayerService:BalancePlayer(player, TeamService:GetTeamCounts(player))
    TeamService:BalanceBots()
end)

EventManager.Listen("ServerPlayer:Disconnect", function(player)
    if player == nil then
        print("ServerPlayer:Disconnect event triggered with nil player, skipping.")
        return
    end

    -- Exclude the leaving player as they may still be in the player list
    TeamService:BalanceBots(player)
end)
