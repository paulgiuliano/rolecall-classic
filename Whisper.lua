-- Whisper.lua
-- Prefilled whisper template generation and sending

local Whisper = {}

-- Determine player's class and role preference (heuristic)
-- Note: This is a best-guess based on character names and roles being used
function Whisper:DetectPlayerRole()
    local _, class = UnitClass("player")
    
    local roleMap = {
        WARRIOR = "tank",
        PALADIN = "tank",
        DRUID = "healer",
        PRIEST = "healer",
        SHAMAN = "healer",
        ROGUE = "dps",
        MAGE = "dps",
        WARLOCK = "dps",
        HUNTER = "dps"
    }
    
    return roleMap[class] or "dps"
end

-- Get player's level
function Whisper:GetPlayerLevel()
    return UnitLevel("player")
end

-- Get player's class name
function Whisper:GetPlayerClass()
    return UnitClass("player")
end

-- Generate a prefilled whisper message for an LFG entry
function Whisper:GenerateTemplate(entry)
    local playerLevel = self:GetPlayerLevel()
    local playerClass = self:GetPlayerClass()
    local playerRole = self:DetectPlayerRole()
    
    -- Build template based on whether we're applying to LFM or posting LFG
    local template
    
    if entry.lfm then
        -- They're looking for more, we're applying
        template = string.format(
            "Hey! %d %s %s for %s, interested?",
            playerLevel,
            playerClass,
            playerRole,
            entry.dungeon
        )
    else
        -- They're looking for group, we might have a group
        template = string.format(
            "I have a group for %s, need anyone?",
            entry.dungeon
        )
    end
    
    return template
end

-- Send a prefilled whisper (opens compose window)
function Whisper:SendTemplateWhisper(entry)
    if not entry or not entry.player then
        return
    end
    
    local template = self:GenerateTemplate(entry)
    
    -- Open whisper window
    SetItemRef("player:" .. entry.player, nil, "LeftButton")
    
    -- If we have a compose frame, fill in the message
    if ChatEdit_GetActiveWindow then
        local editbox = ChatEdit_GetActiveWindow()
        if editbox then
            editbox:SetText(template)
            editbox:HighlightText()
            editbox:SetFocus()
        end
    end
    
    -- Debug output
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(
            string.format("|cFF00FF00[RoleCall]|r Whisper template prepared for %s: %s",
                entry.player, template)
        )
    end
end

_G.Whisper = Whisper
