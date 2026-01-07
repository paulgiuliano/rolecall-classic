-- UI.lua
-- Board frame, scrollable entry list, and row rendering

local UI = {}

-- Backdrop helper to support modern client restrictions
local function ApplyBackdrop(frame, backdrop, r, g, b, a)
    if frame.SetBackdrop then
        frame:SetBackdrop(backdrop)
        if r and g and b and a then
            frame:SetBackdropColor(r, g, b, a)
        end
    else
        -- Fallback: simple color texture
        if not frame._bgTex then
            frame._bgTex = frame:CreateTexture(nil, "BACKGROUND")
            frame._bgTex:SetAllPoints()
        end
        if r and g and b and a then
            frame._bgTex:SetColorTexture(r, g, b, a)
        end
    end
end

-- Main board frame
UI.frame = nil
UI.scrollFrame = nil
UI.entryRows = {}
UI.rowHeight = 20
UI.maxVisibleRows = 15

-- Initialize the UI
function UI:Initialize()
    if not UIParent then
        error("UIParent not available")
    end
    self:CreateMainFrame()
    self:CreateScrollFrame()
end

-- Create main board frame
function UI:CreateMainFrame()
    if self.frame then
        return  -- Already created
    end
    
    if not UIParent then
        error("UIParent not available")
    end
    
    local frame = CreateFrame("Frame", "RoleCallMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(600, 400)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    ApplyBackdrop(frame, {
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    }, 0, 0, 0, 0.8)
    
    -- Title bar
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -15)
    title:SetText("RoleCall Classic - LFG Board")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() UI:Hide() end)
    
    -- Column headers
    local headers = {"Dungeon", "Roles", "Player", "Level", "Time"}
    local headerX = {20, 150, 280, 420, 480}
    
    for i, header in ipairs(headers) do
        local h = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        h:SetPoint("TOPLEFT", frame, "TOPLEFT", headerX[i], -40)
        h:SetText(header)
    end
    
    self.frame = frame
end

-- Create scrollable area
function UI:CreateScrollFrame()
    if self.scrollFrame then
        return
    end
    
    local frame = self.frame
    
    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "RoleCallScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -60)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
    
    -- Content frame
    local contentFrame = CreateFrame("Frame", "RoleCallContentFrame", scrollFrame)
    contentFrame:SetSize(scrollFrame:GetWidth(), self.rowHeight * self.maxVisibleRows)
    scrollFrame:SetScrollChild(contentFrame)
    
    self.scrollFrame = scrollFrame
    self.contentFrame = contentFrame
end

-- Create or update entry rows
function UI:Refresh()
    if not self.frame or not self.contentFrame then
        return
    end
    
    -- Get current entries from data module
    if not RoleCall then
        return
    end
    
    local entries = RoleCall:GetAllEntries()
    
    -- Clear existing rows
    for _, row in ipairs(self.entryRows) do
        if row and row:IsShown() then
            row:Hide()
        end
    end
    self.entryRows = {}
    
    -- Create rows for each entry
    for i, entry in ipairs(entries) do
        local row = self:CreateEntryRow(i, entry)
        if row then
            table.insert(self.entryRows, row)
        end
    end
    
    -- Update content frame height
    self.contentFrame:SetHeight(#self.entryRows * self.rowHeight)
end

-- Create a single entry row
function UI:CreateEntryRow(index, entry)
    if not self.contentFrame then
        return nil
    end
    
    local row = CreateFrame("Button", "RoleCallRow" .. index, self.contentFrame, "BackdropTemplate")
    row:SetSize(self.contentFrame:GetWidth(), self.rowHeight)
    row:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, -(index - 1) * self.rowHeight)
    
    -- Alternating row colors
    local function setBaseColor()
        if index % 2 == 0 then
            ApplyBackdrop(row, {bgFile = "Interface/Tooltips/UI-Tooltip-Background"}, 0.1, 0.1, 0.15, 0.5)
        else
            ApplyBackdrop(row, {bgFile = "Interface/Tooltips/UI-Tooltip-Background"}, 0, 0, 0, 0.3)
        end
    end
    setBaseColor()
    
    -- Row data
    row.entry = entry
    
    -- Create text fields for each column
    local function CreateColumnText(x, width)
        local text = row:CreateFontString(nil, "OVERLAY", "ChatFontSmall")
        text:SetPoint("TOPLEFT", row, "TOPLEFT", x, -2)
        text:SetSize(width, self.rowHeight)
        text:SetJustifyH("LEFT")
        return text
    end
    
    row.dungeon = CreateColumnText(5, 140)
    row.roles = CreateColumnText(150, 120)
    row.player = CreateColumnText(280, 130)
    row.level = CreateColumnText(420, 50)
    row.time = CreateColumnText(480, 80)
    
    -- Populate text
    row.dungeon:SetText(entry.dungeon or "?")
    
    -- Format roles
    local roleList = {}
    if entry.roles.tank then table.insert(roleList, "T") end
    if entry.roles.healer then table.insert(roleList, "H") end
    if entry.roles.dps then table.insert(roleList, "D") end
    row.roles:SetText(table.concat(roleList, ", ") or "-")
    
    row.player:SetText(entry.player or "?")
    row.level:SetText(entry.level and tostring(entry.level) or "?")
    
    -- Format time ago
    local timeDiff = time() - entry.timestamp
    if timeDiff < 60 then
        row.time:SetText(timeDiff .. "s ago")
    elseif timeDiff < 3600 then
        row.time:SetText(math.floor(timeDiff / 60) .. "m ago")
    else
        row.time:SetText(math.floor(timeDiff / 3600) .. "h ago")
    end
    
    -- Hover highlight and click to whisper
    row:SetScript("OnEnter", function()
        ApplyBackdrop(row, {bgFile = "Interface/Tooltips/UI-Tooltip-Background"}, 0.2, 0.2, 0.3, 0.8)
    end)
    
    row:SetScript("OnLeave", function()
        setBaseColor()
    end)
    
    row:SetScript("OnClick", function()
        if Whisper then
            Whisper:SendTemplateWhisper(entry)
        end
    end)
    
    return row
end

-- Toggle board visibility
function UI:Toggle()
    if self.frame then
        if self.frame:IsShown() then
            self:Hide()
        else
            self:Show()
        end
    else
        self:Initialize()
        self:Show()
    end
end

-- Show the board
function UI:Show()
    if self.frame then
        self.frame:Show()
        self:Refresh()
    end
end

-- Hide the board
function UI:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

_G.UI = UI
