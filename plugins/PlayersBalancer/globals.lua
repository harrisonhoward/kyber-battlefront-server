---@meta

---@alias Player
---| { isBot: boolean, team: number, name: string, playerId: number, score: number, kills: number, assists: number, deaths: number, battlepoints: number, SetTeam: fun(self: Player, team: number), SetScore: fun(self: Player, amount: number), SetKills: fun(self: Player, amount: number), SetAssists: fun(self: Player, amount: number), SetDeaths: fun(self: Player, amount: number), SetBattlepoints: fun(self: Player, amount: number) }

---@class EventManagerClass
---@field Listen fun(event: string, callback: function, context?: any)
EventManager = EventManager

---@class PlayerManagerClass
---@field GetPlayers fun(): Player[]
PlayerManager = PlayerManager

---@class ConsoleClass
---@field GetSettings fun(setting: string): table|nil
---@field Execute fun(command: string)
Console = Console
