-- Parser.lua
-- Extract structured intent from raw LFG chat messages

local Parser = {}

-- Normalized dungeon names mapping
local DUNGEON_ALIASES = {
    -- Blackrock Depths
    ["brd"] = "BRD",
    ["blackrock depths"] = "BRD",
    
    -- Stratholme
    ["strat"] = "Strat",
    ["stratholme"] = "Strat",
    ["strat live"] = "Strat Live",
    ["strat ud"] = "Strat UD",
    
    -- Scholomance
    ["scholo"] = "Scholo",
    ["scholomance"] = "Scholo",
    
    -- Upper Blackrock Spire
    ["ubrs"] = "UBRS",
    ["upper blackrock"] = "UBRS",
    
    -- World Bosses
    ["dm"] = "DM",
    ["dire maul"] = "DM",
    ["dm-n"] = "DM-N",
    ["dm-e"] = "DM-E",
    ["dm-w"] = "DM-W",
    
    -- Low level dungeons
    ["sm"] = "SM",
    ["sm cath"] = "SM Cath",
    ["sm arm"] = "SM Armory",
    ["sm lib"] = "SM Library",
    ["sm graveyard"] = "SM Graveyard",
    
    ["bfd"] = "BFD",
    ["blackfathom"] = "BFD",
    
    ["wc"] = "Wailing Caverns",
    ["wailing caverns"] = "Wailing Caverns",
    ["vc"] = "Uldaman",
    ["uldaman"] = "Uldaman",
    ["rfc"] = "Ragefire",
    
    -- TBC dungeons
    ["blood furnace"] = "Blood Furnace",
    ["shattered halls"] = "Shattered Halls",
    ["slave pens"] = "Slave Pens",
    ["underbog"] = "Underbog",
    ["sethekk"] = "Sethekk Halls",
    ["durnhold"] = "Durnhold",
}

-- Role keywords
local ROLE_KEYWORDS = {
    tank = {"tank", "tanking", "prot"},
    healer = {"healer", "healing", "heal", "resto", "priest", "shaman", "druid"},
    dps = {"dps", "damage", "dd", "dagger", "rogue", "mage", "warlock"}
}

-- Extract normalized dungeon from message
function Parser:ExtractDungeon(message)
    local lower = string.lower(message)
    
    -- Try exact matches first
    for alias, normalized in pairs(DUNGEON_ALIASES) do
        if string.find(lower, alias, 1, true) then
            return normalized
        end
    end
    
    return nil
end

-- Extract roles from message
function Parser:ExtractRoles(message)
    local roles = {tank = false, healer = false, dps = false}
    local lower = string.lower(message)
    
    for role, keywords in pairs(ROLE_KEYWORDS) do
        for _, keyword in ipairs(keywords) do
            if string.find(lower, keyword, 1, true) then
                roles[role] = true
                break
            end
        end
    end
    
    return roles
end

-- Extract player level from message (looks for numbers like 58, 60, etc)
function Parser:ExtractLevel(message)
    local numbers = string.match(message, "(%d%d)")
    if numbers then
        local level = tonumber(numbers)
        if level >= 1 and level <= 60 then
            return level
        end
    end
    return nil
end

-- Determine if message is LFM (Looking For More) or LFG (Looking For Group)
function Parser:IsLFM(message)
    local lower = string.lower(message)
    
    -- LFM patterns
    if string.find(lower, "lfm", 1, true) then return true end
    if string.find(lower, "looking for more", 1, true) then return true end
    if string.find(lower, "need", 1, true) then return true end
    
    -- LFG patterns
    if string.find(lower, "lfg", 1, true) then return false end
    if string.find(lower, "looking for group", 1, true) then return false end
    if string.find(lower, "lf%d", 1, false) then return false end  -- LF2M, LF3M, etc.
    
    -- Default heuristic: if roles are present, it's likely LFM
    local roles = self:ExtractRoles(message)
    if roles.tank or roles.healer or roles.dps then
        return true
    end
    
    return false
end

-- Main parsing function: convert raw message to structured intent
function Parser:Parse(message, player)
    local dungeon = self:ExtractDungeon(message)
    if not dungeon then
        return nil  -- No dungeon found, skip this message
    end
    
    local roles = self:ExtractRoles(message)
    local level = self:ExtractLevel(message)
    local lfm = self:IsLFM(message)
    
    return {
        player = player,
        dungeon = dungeon,
        roles = roles,
        level = level,
        lfm = lfm,
        rawMessage = message
    }
end

_G.Parser = Parser
