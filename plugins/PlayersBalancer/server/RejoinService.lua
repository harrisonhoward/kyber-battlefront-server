local PlayerService = require "PlayerService"

-- A rejoining player goes back to their old team unless it would put that team
-- more than this many players ahead
local MAX_REJOIN_TEAM_DIFFERENCE = 2

---@alias PlayerSnapshot
---| { team: number, score: number, kills: number, assists: number, deaths: number, battlepoints: number }

---@class RejoinService
---@field leftPlayers table<number, PlayerSnapshot> -- Players who left during the current level, by playerId
---@field Remember fun(self: RejoinService, player: Player) -- Stores the leaving player's team and stats
---@field RestoreTeam fun(self: RejoinService, player: Player, teamCounts: {team1: number, team2: number}): boolean -- False if the player did not leave this level
---@field RestoreStats fun(self: RejoinService, player: Player) -- Restores the stats and forgets the player
---@field Clear fun(self: RejoinService) -- Forgets every player, called when the level ends
RejoinService = {
    leftPlayers = {},

    Remember = function(self, player)
        -- Bots and spectators are not on a playable team
        if player.isBot or (player.team ~= 1 and player.team ~= 2) then
            return
        end

        self.leftPlayers[player.playerId] = {
            team = player.team,
            score = player.score,
            kills = player.kills,
            assists = player.assists,
            deaths = player.deaths,
            battlepoints = player.battlepoints,
        }
        print(string.format("Remembered team %d and stats for leaving player %s", player.team, player.name))
    end,

    RestoreTeam = function(self, player, teamCounts)
        local snapshot = self.leftPlayers[player.playerId]
        if snapshot == nil then
            return false
        end

        local ownCount = (snapshot.team == 1) and teamCounts.team1 or teamCounts.team2
        local otherCount = (snapshot.team == 1) and teamCounts.team2 or teamCounts.team1
        if (ownCount + 1) - otherCount > MAX_REJOIN_TEAM_DIFFERENCE then
            print(string.format("Team %d is too far ahead for rejoining player %s, balancing instead",
                snapshot.team, player.name))
            PlayerService:BalancePlayer(player, teamCounts)
            return true
        end

        player:SetTeam(snapshot.team)
        print(string.format("Returned rejoining player %s to team %d", player.name, snapshot.team))
        return true
    end,

    RestoreStats = function(self, player)
        local snapshot = self.leftPlayers[player.playerId]
        if snapshot == nil then
            return
        end
        self.leftPlayers[player.playerId] = nil

        player:SetScore(snapshot.score)
        player:SetKills(snapshot.kills)
        player:SetAssists(snapshot.assists)
        player:SetDeaths(snapshot.deaths)
        player:SetBattlepoints(snapshot.battlepoints)
        print(string.format("Restored stats for rejoining player %s", player.name))
    end,

    Clear = function(self)
        self.leftPlayers = {}
    end,
}

return RejoinService
