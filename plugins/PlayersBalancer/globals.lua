---@meta

---@alias Player
---| { isBot: boolean, team: number, name: string, SetTeam: fun(self: Player, team: number) }

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
