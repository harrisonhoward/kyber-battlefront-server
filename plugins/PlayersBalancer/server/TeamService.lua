local Config = require "config"
local ServerService = require "ServerService"
local PlayerService = require "PlayerService"

---@class TeamService
---@field GetAutoPlayerSettings fun(self: TeamService, silent?: boolean): table|nil -- Console.GetSettings with extra handling
---@field GetTeamCounts fun(self: TeamService): { team1: number, team2: number }
---@field GetPlayerCount fun(self: TeamService): number -- Player count without bots
---@field BalanceBots fun(self: TeamService) -- Will ensure both teams have the same amount of players
---@field ResetBots fun(self: TeamService) -- Resets the bot counts and active gamemode back to 0
---@field RandomiseTeams fun(self: TeamService)
TeamService = {

    GetAutoPlayerSettings = function(self, silent)
        if ServerService.activeGameMode == nil then
            return nil
        end

        local settings = Console.GetSettings("AutoPlayers")
        if settings == nil then
            if silent ~= true then
                return
            end
            print("AutoPlayer settings not found!")
            return nil
        end

        return settings
    end,

    GetTeamCounts = function(self)
        local teamCounts = {
            team1 = 0,
            team2 = 0,
        }

        local players = PlayerManager.GetPlayers()
        for _, player in ipairs(players) do
            if player.isBot then
                goto continue
            end

            local team = player.team
            if team == 1 then
                teamCounts.team1 = teamCounts.team1 + 1
            elseif team == 2 then
                teamCounts.team2 = teamCounts.team2 + 1
            end

            ::continue::
        end

        return teamCounts
    end,

    GetPlayerCount = function(self)
        local teamCounts = TeamService:GetTeamCounts()
        return teamCounts.team1 + teamCounts.team2
    end,

    BalanceBots = function(self)
        local settings = self:GetAutoPlayerSettings()
        if settings == nil then
            return
        end

        local teamCounts = TeamService:GetTeamCounts()
        local desiredPlayersPerTeam = math.floor(
            math.floor(ServerService.activeGameMode.maxPlayers * Config.botDensity) / 2
        )
        local botsNeededPerTeam = {
            team1 = math.max(0, desiredPlayersPerTeam - teamCounts.team1),
            team2 = math.max(0, desiredPlayersPerTeam - teamCounts.team2),
        }

        -- Function to apply these values for both teams
        ---@param team 'team1'|'team2'
        ---@param settingsKey string
        local function balanceTeam(team, settingsKey)
            local botsNeeded = botsNeededPerTeam[team]
            if settings[settingsKey] == botsNeeded then
                return
            end

            settings[settingsKey] = botsNeeded
            print(
                string.format(
                    "Adjusted %s bot count to %d for balancing",
                    team,
                    botsNeeded
                )
            )
        end

        balanceTeam("team1", "forceFillGameplayBotsTeam1")
        balanceTeam("team2", "forceFillGameplayBotsTeam2")
    end,

    ResetBots = function(self)
        local settings = self:GetAutoPlayerSettings()
        if settings == nil then
            return
        end

        settings.forceFillGameplayBotsTeam1 = 0
        settings.forceFillGameplayBotsTeam2 = 0
        ServerService.activeGameMode = nil
    end,

    RandomiseTeams = function(self)
        if ServerService.activeGameMode == nil then
            return
        end

        ---@type number[] -- List of teams that will be shuffled and applied to players.
        local randomTeamList = {}
        local playerCount = TeamService:GetPlayerCount()

        -- No players online
        if playerCount <= 0 then
            print("No players online, skipping team randomisation.")
            return
        end

        -- Less than two players online, we swap the teams they are on instead.
        if playerCount <= 2 then
            Console.Execute("Kyber.Broadcast **KYBER:** Not enough players to shuffle. Swapping teams instead.")
            local players = PlayerManager.GetPlayers()
            for _, player in ipairs(players) do
                PlayerService:SwapPlayersTeam(player)
            end
            return
        end
        Console.Execute("Kyber.Broadcast **KYBER:** Shuffling teams.")

        -- Fill the team list
        for i = 1, playerCount - (playerCount // 2), 1 do
            table.insert(randomTeamList, 1)
        end
        for i = (playerCount - (playerCount // 2)) + 1, playerCount, 1 do
            table.insert(randomTeamList, 2)
        end

        -- Fisher yates shuffle
        for i = #randomTeamList, 2, -1 do
            local j = math.random(i)
            randomTeamList[i], randomTeamList[j] = randomTeamList[j], randomTeamList[i]
        end

        -- Set players team
        local players = PlayerManager.GetPlayers()
        local i = 1
        for _, player in ipairs(players) do
            if player.isBot then
                goto continue
            end

            player:SetTeam(randomTeamList[i])
            i = i + 1

            ::continue::
        end
    end,
}

return TeamService
