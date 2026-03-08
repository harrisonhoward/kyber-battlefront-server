---@class PlayerService
---@field SwapPlayersTeam fun(self: PlayerService, player: Player)
---@field BalancePlayer fun(self: PlayerService, player: Player, teamCounts: {team1: number, team2: number}) -- Balances the player to a team
PlayerService = {
    SwapPlayersTeam = function(self, player)
        if player.isBot then
            return
        end

        player:SetTeam((player.team == 1) and 2 or 1)

        print(
            string.format("Swapped player %s to team %d", player.name, player.team)
        )
    end,

    BalancePlayer = function(self, player, teamCounts)
        -- If team 1 has more players, set to team 2
        if teamCounts.team1 > teamCounts.team2 then
            player:SetTeam(2)
            -- If team 2 has more players, set to team 1
        elseif teamCounts.team2 > teamCounts.team1 then
            player:SetTeam(1)
            -- Otherwise random team
        else
            player:SetTeam(math.random(1, 2))
        end

        print(
            string.format("Balanced player %s to team %d", player.name, player.team)
        )
    end,
}

return PlayerService
