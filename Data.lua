-- Data.lua
-- In-memory session storage for LFG entries with de-duplication

local RoleCall = {}

-- Master entries table: player name -> entry
RoleCall.entries = {}

-- Helper function to get or create an entry for a player
function RoleCall:GetOrCreateEntry(player)
    if not self.entries[player] then
        self.entries[player] = {
            player = player,
            dungeon = nil,
            roles = {
                tank = false,
                healer = false,
                dps = false
            },
            level = nil,
            lfm = false,
            timestamp = time(),
            reposts = 0
        }
    end
    return self.entries[player]
end

-- Update an existing entry and increment repost counter
function RoleCall:UpdateEntry(player, data)
    local entry = self:GetOrCreateEntry(player)
    
    -- Preserve player name and increment reposts if we're updating
    if entry.timestamp then
        entry.reposts = (entry.reposts or 0) + 1
    end
    
    entry.dungeon = data.dungeon
    entry.roles = data.roles or entry.roles
    entry.level = data.level or entry.level
    entry.lfm = data.lfm or entry.lfm
    entry.timestamp = time()
    
    return entry
end

-- Get all entries in chronological order
function RoleCall:GetAllEntries()
    local result = {}
    for _, entry in pairs(self.entries) do
        table.insert(result, entry)
    end
    
    -- Sort by timestamp, newest first
    table.sort(result, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    return result
end

-- Clear old entries (older than maxAge seconds, default 10 minutes)
function RoleCall:PruneOldEntries(maxAge)
    maxAge = maxAge or 600
    local now = time()
    
    for player, entry in pairs(self.entries) do
        if now - entry.timestamp > maxAge then
            self.entries[player] = nil
        end
    end
end

-- Reset all entries
function RoleCall:ClearAll()
    self.entries = {}
end

_G.RoleCall = RoleCall
