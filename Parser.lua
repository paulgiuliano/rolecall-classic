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
    
    -- Dire Maul
    ["dm"] = "DM",
    ["dire maul"] = "DM",
    ["dm-n"] = "DM-N",
    ["dm-e"] = "DM-E",
    ["dm-w"] = "DM-W",
    ["dmf"] = "DMF",
    ["darkmoon faire"] = "DMF",
    ["darkmoon"] = "DMF",
    
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
    
    -- Raids
    ["zg"] = "ZG",
    ["aq20"] = "AQ20",
    ["a20"] = "AQ20",
    ["aq40"] = "AQ40",
    ["a40"] = "AQ40",
    ["bwl"] = "BWL",
    ["blackwing"] = "BWL",
    ["molten core"] = "MC",
    ["mc"] = "MC",
    ["naxx"] = "NAXX",
    ["naxxramas"] = "NAXX",
    
    -- TBC dungeons
    ["blood furnace"] = "Blood Furnace",
    ["shattered halls"] = "Shattered Halls",
    ["slave pens"] = "Slave Pens",
    ["underbog"] = "Underbog",
    ["sethekk"] = "Sethekk Halls",
    ["durnhold"] = "Durnhold",
    
    -- Other instances
    ["zf"] = "Zul'Farrak",
    ["zul farrak"] = "Zul'Farrak",
}

-- Full names for normalized dungeon names (for display)
local DUNGEON_FULL_NAMES = {
    ["BRD"] = "Blackrock Depths (BRD)",
    ["Strat"] = "Stratholme (Strat)",
    ["Strat Live"] = "Stratholme Live (Strat Live)",
    ["Strat UD"] = "Stratholme Undead (Strat UD)",
    ["Scholo"] = "Scholomance (Scholo)",
    ["UBRS"] = "Upper Blackrock Spire (UBRS)",
    ["DM"] = "Dire Maul (DM)",
    ["DM-N"] = "Dire Maul North (DM-N)",
    ["DM-E"] = "Dire Maul East (DM-E)",
    ["DM-W"] = "Dire Maul West (DM-W)",
    ["DMF"] = "Darkmoon Faire (DMF)",
    ["SM"] = "Shadowfang Keep (SM)",
    ["SM Cath"] = "Shadowfang Keep Cathedral (SM Cath)",
    ["SM Armory"] = "Shadowfang Keep Armory (SM Armory)",
    ["SM Library"] = "Shadowfang Keep Library (SM Library)",
    ["SM Graveyard"] = "Shadowfang Keep Graveyard (SM Graveyard)",
    ["BFD"] = "Blackfathom Deeps (BFD)",
    ["Wailing Caverns"] = "Wailing Caverns (WC)",
    ["Uldaman"] = "Uldaman (VC)",
    ["Ragefire"] = "Ragefire Chasm (RFC)",
    ["ZG"] = "Zul'Aman (ZG)",
    ["AQ20"] = "Temple of Ahn'Qiraj (AQ20)",
    ["AQ40"] = "Temple of Ahn'Qiraj (AQ40)",
    ["BWL"] = "Blackwing Lair (BWL)",
    ["MC"] = "Molten Core (MC)",
    ["NAXX"] = "Naxxramas (NAXX)",
    ["Blood Furnace"] = "Blood Furnace (Blood Furnace)",
    ["Shattered Halls"] = "Shattered Halls (Shattered Halls)",
    ["Slave Pens"] = "Slave Pens (Slave Pens)",
    ["Underbog"] = "Underbog (Underbog)",
    ["Sethekk Halls"] = "Sethekk Halls (Sethekk Halls)",
    ["Durnhold"] = "Durnhold (Durnhold)",
    ["Zul'Farrak"] = "Zul'Farrak (ZF)",
}

-- Role keywords (actual roles and classes as indicators of LFG posts)
local ROLE_KEYWORDS = {
    tank = {"tank", "tanking", "prot", "warrior", "paladin"},
    healer = {"healer", "healing", "heal", "resto", "priest", "shaman", "druid"},
    dps = {"dps", "damage", "dd", "dagger", "rogue", "mage", "warlock", "hunter"}
}

-- Class to role mapping (for extracting specific class names)
local CLASS_TO_ROLE = {
    ["warrior"] = "tank",
    ["paladin"] = "tank",
    ["priest"] = "healer",
    ["shaman"] = "healer",
    ["druid"] = "healer",
    ["rogue"] = "dps",
    ["mage"] = "dps",
    ["warlock"] = "dps",
    ["hunter"] = "dps"
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

-- Get full display name for a dungeon (e.g., "UBRS" -> "Upper Blackrock Spire (UBRS)")
function Parser:GetDungeonDisplayName(normalizedName)
    return DUNGEON_FULL_NAMES[normalizedName] or normalizedName
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

-- Extract specific class names from message (e.g., "Priest", "Mage", "Warrior")
function Parser:ExtractClasses(message)
    local classes = {}
    local lower = string.lower(message)
    
    for class, _ in pairs(CLASS_TO_ROLE) do
        if string.find(lower, class, 1, true) then
            table.insert(classes, class:sub(1, 1):upper() .. class:sub(2))  -- Capitalize
        end
    end
    
    return classes
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
    local roles = self:ExtractRoles(message)
    local classes = self:ExtractClasses(message)
    local level = self:ExtractLevel(message)
    local lfm = self:IsLFM(message)
    
    -- Allow parsing if dungeon is found OR if any role is explicitly mentioned (e.g., "LFM Mage")
    if not dungeon and not (roles.tank or roles.healer or roles.dps) then
        return nil  -- No dungeon and no roles, skip
    end
    
    return {
        player = player,
        dungeon = dungeon or "?",  -- Use "?" if no dungeon found
        roles = roles,
        classes = classes,  -- List of specific classes mentioned
        level = level,
        lfm = lfm,
        rawMessage = message
    }
end

_G.Parser = Parser
