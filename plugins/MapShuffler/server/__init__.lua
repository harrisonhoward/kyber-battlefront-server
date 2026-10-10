-- Tracks whether the rotation has been shuffled since the server started
local hasShuffledOnStart = false

-- Attempts to find an order without the same level twice in a row, after
-- which the last shuffle is used (e.g. every entry shares a level)
local MAX_SHUFFLE_ATTEMPTS = 20

---@param entries MapRotationEntry[]
local function shuffleEntries(entries)
    -- Fisher yates shuffle
    for i = #entries, 2, -1 do
        local j = math.random(i)
        entries[i], entries[j] = entries[j], entries[i]
    end
end

-- Levels are compared without the mode, as the same level can be in the
-- rotation for multiple modes (e.g. Yavin in conquest and galactic assault)
---@param entries MapRotationEntry[]
---@param currentEntry MapRotationEntry|nil
---@return boolean
local function hasRepeatedLevel(entries, currentEntry)
    if currentEntry ~= nil and entries[1].level == currentEntry.level then
        return true
    end

    for i = 2, #entries do
        if entries[i].level == entries[i - 1].level then
            return true
        end
    end

    return false
end

-- Shuffles the rotation and resets it so the first shuffled entry loads next.
---@param currentEntry MapRotationEntry|nil The entry currently being played, kept out of the next slot
local function shuffleRotation(currentEntry)
    local entries = MapRotation.GetList()
    if #entries < 2 then
        print("Map rotation has fewer than two entries, skipping shuffle.")
        return
    end

    -- Avoid playing the same level twice in a row
    for _ = 1, MAX_SHUFFLE_ATTEMPTS do
        shuffleEntries(entries)
        if not hasRepeatedLevel(entries, currentEntry) then
            break
        end
    end

    -- Clear requires the first entry and resets the rotation index
    MapRotation.Clear(entries[1].level, entries[1].mode)
    for i = 2, #entries do
        MapRotation.AddMap(entries[i].level, entries[i].mode)
    end

    print(string.format("Shuffled map rotation with %d entries. Next map: %s (%s)",
        #entries, entries[1].level, entries[1].mode))
end

-- The entry currently being played, which is the one before the next entry index
---@return MapRotationEntry|nil
local function getCurrentEntry()
    local entries = MapRotation.GetList()
    return entries[MapRotation.GetCurrentEntryIndex() - 1]
end

-- Shuffle once the first level has loaded, as the rotation is populated by then
EventManager.Listen("Level:Loaded", function()
    if hasShuffledOnStart then
        return
    end
    hasShuffledOnStart = true

    shuffleRotation(getCurrentEntry())
end)

-- Ran before Kyber picks the next entry, if the index is past the end then the
-- rotation is about to wrap back to the start, so reshuffle it instead.
EventManager.Listen("Level:Complete", function()
    local entries = MapRotation.GetList()
    if MapRotation.GetCurrentEntryIndex() <= #entries then
        return
    end

    print("Map rotation completed a cycle, reshuffling.")
    shuffleRotation(entries[#entries])
end)
