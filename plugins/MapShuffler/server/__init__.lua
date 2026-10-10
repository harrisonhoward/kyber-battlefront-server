-- Tracks whether the rotation has been shuffled since the server started
local hasShuffledOnStart = false

---@param a MapRotationEntry
---@param b MapRotationEntry
---@return boolean
local function isSameEntry(a, b)
    return a.level == b.level and a.mode == b.mode
end

-- Shuffles the rotation and resets it so the first shuffled entry loads next.
---@param currentEntry MapRotationEntry|nil The entry currently being played, kept out of the next slot
local function shuffleRotation(currentEntry)
    local entries = MapRotation.GetList()
    if #entries < 2 then
        print("Map rotation has fewer than two entries, skipping shuffle.")
        return
    end

    -- Fisher yates shuffle
    for i = #entries, 2, -1 do
        local j = math.random(i)
        entries[i], entries[j] = entries[j], entries[i]
    end

    -- Avoid playing the same map twice in a row
    if currentEntry ~= nil and isSameEntry(entries[1], currentEntry) then
        local j = math.random(2, #entries)
        entries[1], entries[j] = entries[j], entries[1]
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

if MapRotation == nil then
    print("MapRotation is not available on this Kyber version. MapShuffler is disabled.")
    return
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
