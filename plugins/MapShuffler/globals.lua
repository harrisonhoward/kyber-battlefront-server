---@meta

---@alias MapRotationEntry
---| { level: string, mode: string }

---@class EventManagerClass
---@field Listen fun(event: string, callback: function, context?: any)
EventManager = EventManager

---@class MapRotationClass
---@field AddMap fun(level: string, mode: string) -- Adds an entry to the end of the rotation
---@field Clear fun(level: string, mode: string) -- Clears the rotation, leaving the given entry as the next map
---@field GetNextMap fun(): MapRotationEntry
---@field RemoveNextMap fun()
---@field GetCurrentEntryIndex fun(): integer -- 1-based index of the next entry to load
---@field GetList fun(): MapRotationEntry[]
MapRotation = MapRotation
