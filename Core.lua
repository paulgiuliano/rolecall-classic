-- Core.lua
-- Event handling and chat message capture

local Core = {}

-- Initialize event frame
local eventFrame = CreateFrame("Frame", "RoleCallEventFrame")
eventFrame:RegisterEvent("CHAT_MSG_CHANNEL")
eventFrame:RegisterEvent("CHAT_MSG_SAY")
eventFrame:RegisterEvent("CHAT_MSG_YELL")
eventFrame:RegisterEvent("ADDON_LOADED")

-- Chat channels to monitor
local MONITORED_CHANNELS = {
    ["LookingForGroup"] = true,
    ["Trade"] = true,
}

-- Normalize channel name from message payload (e.g., "Trade - Ironforge" -> "Trade")
local function NormalizeChannelName(name)
    if not name or type(name) ~= "string" then return nil end
    -- Remove optional leading index like "1. "
    name = name:gsub("^%s*%d+%s*%.%s*", "")
    -- Strip zone suffix after " - "
    local base = name:match("^(.-)%s*%-%s*") or name
    -- Trim whitespace
    base = base:gsub("^%s+", ""):gsub("%s+$", "")
    return base
end

-- Handle chat messages
function Core:OnChatMessage(event, message, author, language, channelName, playerName, flags, unknown, channelNumber, lineID, guid, bnSenderID, isMobile, isSystemMessage, autoTranslated)
    -- Only process messages from monitored channels (for CHANNEL events)
    if event == "CHAT_MSG_CHANNEL" then
        local base = NormalizeChannelName(channelName)
        if not (base and MONITORED_CHANNELS[base]) then
            return
        end
    else
        -- Ignore SAY/YELL unless needed in future
        return
    end
    
    -- Skip if no parser or data module
    if not Parser or not RoleCall then
        return
    end
    
    -- Parse the message
    local parsed = Parser:Parse(message, author)
    if parsed then
        -- Update or create entry in data module
        RoleCall:UpdateEntry(author, parsed)
        
        -- Trigger UI update if available
        if UI and UI.Refresh then
            UI:Refresh()
        end
        
        -- Debug output
        self:DebugPrint(string.format(
            "[%s] %s: %s (%s) - %s",
            channelName,
            parsed.player,
            parsed.dungeon,
            parsed.lfm and "LFM" or "LFG",
            parsed.level and "Lv" .. parsed.level or "?"
        ))
    end
end

-- Debug print to chat frame
function Core:DebugPrint(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[RoleCall]|r " .. msg)
    end
end

-- Initialize addon
function Core:OnAddonLoaded(addon)
    if addon ~= "RoleCall" then return end
    
    self:DebugPrint("RoleCall Classic v0.1.0 loaded!")
    self:DebugPrint("Monitoring LookingForGroup and Trade channels.")
    
    -- Start automatic entry pruning (every 60 seconds, prune entries older than 10 minutes)
    C_Timer.NewTicker(60, function()
        if RoleCall and RoleCall.PruneOldEntries then
            RoleCall:PruneOldEntries(600)  -- 10 minutes
            -- Refresh UI if visible and RoleCall has changed
            if UI and UI.Refresh and UI.frame and UI.frame:IsShown() then
                UI:Refresh()
            end
        end
    end)
    
    -- Initialize UI if available
    if UI and UI.Initialize then
        local success, err = pcall(function()
            UI:Initialize()
        end)
        if success then
            self:DebugPrint("UI initialized. Type /rolecall or /rcc to show the board.")
        else
            self:DebugPrint("ERROR: Failed to initialize UI: " .. tostring(err))
        end
    else
        self:DebugPrint("WARNING: UI module not found!")
    end
    
    -- Register slash commands after all modules are loaded
    local success, err = pcall(function()
        SLASH_ROLECALL1 = "/rolecall"
        SLASH_ROLECALL2 = "/rcc"
        SlashCmdList["ROLECALL"] = function(msg)
            if UI and UI.Toggle then
                UI:Toggle()
                Core:DebugPrint("Slash command invoked; toggled board.")
            else
                Core:DebugPrint("Slash command received but UI is not available.")
            end
        end
    end)
    if not success then
        self:DebugPrint("ERROR: Failed to register slash commands: " .. tostring(err))
    else
        self:DebugPrint("Slash commands registered successfully.")
    end
end

-- Event dispatcher
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" then
        Core:OnChatMessage(event, ...)
    elseif event == "ADDON_LOADED" then
        Core:OnAddonLoaded(...)
    end
end)

_G.Core = Core
