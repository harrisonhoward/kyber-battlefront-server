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
    local kyberSettings = Console.GetSettings("Kyber")
    if kyberSettings ~= nil then
        kyberSettings.disableTeamBalancing = true
    end
    local wsSettings = Console.GetSettings("Whiteshark")
    if wsSettings ~= nil then
        wsSettings.autoBalanceTeamsOnNeutral = false
    end
    print("Disabled traditional team balancing in favour for PlayersBalancer's")

    -- If config shuffler not enabled then do not shuffle the teams
    if Config.enableShuffler == true then
        TeamService:RandomiseTeams()
    end
    TeamService:BalanceBots()
end

-- No event for player leaving on STABLE. This is a workaround to balance every 5 seconds instead.
local elapsedTime = 0
EventManager.Listen("Server:UpdatePre", function(delta)
    elapsedTime = elapsedTime + delta
    if elapsedTime >= 5 then
        elapsedTime = elapsedTime - 5
        TeamService:BalanceBots()
    end
end)

EventManager.Listen("Server:Init", function()
    ServerService.serverInitialised = true
    init()
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

EventManager.Listen("Server:PlayerJoined", function(player)
    if player == nil then
        print("PlayerJoined event triggered with nil player, skipping.")
        return
    end

    PlayerService:BalancePlayer(player, TeamService:GetTeamCounts())
    TeamService:BalanceBots()
end)
