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
UI.sortBy = "time"  -- Default sort column
UI.sortAsc = false  -- Default to descending (newest first)

-- Column layout: proportional widths (0-1) and minimum pixel widths
UI.columnLayout = {
    {name = "Dungeon", proportion = 0.35, minWidth = 180},
    {name = "Role/Class", proportion = 0.20, minWidth = 120},
    {name = "Player", proportion = 0.25, minWidth = 140},
    {name = "Level", proportion = 0.10, minWidth = 60},
    {name = "Time", proportion = 0.10, minWidth = 80}
}

-- Calculate column positions and widths based on frame width
function UI:CalculateColumnLayout(frameWidth)
    local leftPadding = 15
    local rightPadding = 40  -- Account for scrollbar
    local availableWidth = frameWidth - leftPadding - rightPadding

    local columns = {}
    local x = leftPadding

    -- Sum min widths and proportions
    local sumMin, sumProp = 0, 0
    for _, c in ipairs(self.columnLayout) do
        sumMin = sumMin + (c.minWidth or 0)
        sumProp = sumProp + (c.proportion or 0)
    end

    -- Ensure we never allocate below min widths; distribute any remaining space
    local remaining = math.max(0, availableWidth - sumMin)

    for _, col in ipairs(self.columnLayout) do
        local bonus = 0
        if sumProp > 0 and remaining > 0 then
            bonus = remaining * (col.proportion / sumProp)
        end
        local width = (col.minWidth or 0) + bonus
        table.insert(columns, { name = col.name, x = x, width = width })
        x = x + width
    end

    return columns
end

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
    frame:SetSize(700, 420)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    -- Enable dragging of the board
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    -- Enable resizing
    frame:SetResizable(true)
    -- Compute minimum frame width from column minimums and paddings to ensure all columns visible
    local minWidth = (function()
        local sumMin = 0
        for _, c in ipairs(UI.columnLayout) do
            sumMin = sumMin + (c.minWidth or 0)
        end
        local leftPadding = 15
        local rightPadding = 40
        return sumMin + leftPadding + rightPadding
    end)()
    -- Lock width to default, allow vertical resize only
    local defaultWidth = 900
    frame:SetResizeBounds(defaultWidth, 260, defaultWidth, 900)
    
    -- Handle resize to update scroll frame
    frame:SetScript("OnSizeChanged", function(self, width, height)
        if UI.scrollFrame then
            -- Update scroll frame size when window is resized
            UI.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -60)
            UI.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
        end
        -- Refresh to recalculate column positions
        UI:UpdateColumnHeaders()
        UI:Refresh()
    end)
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
    
    -- Notifications toggle button
    local notifyBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    notifyBtn:SetSize(50, 22)
    notifyBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -125, -12)
    notifyBtn:SetText("Notify")
    notifyBtn:SetScript("OnClick", function()
        if Core and Core.ToggleNotifications then
            local enabled = Core:ToggleNotifications()
            notifyBtn:SetText(enabled and "Notify" or "Mute")
            -- Color the text based on state
            local fontString = notifyBtn:GetFontString()
            if fontString then
                if enabled then
                    fontString:SetTextColor(0, 1, 0)  -- Green
                else
                    fontString:SetTextColor(1, 0, 0)  -- Red
                end
            end
        end
    end)
    -- Set initial color
    local notifyFontString = notifyBtn:GetFontString()
    if notifyFontString then
        notifyFontString:SetTextColor(0, 1, 0)  -- Green for ON
    end
    
    -- Clear Board button
    local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearBtn:SetSize(80, 22)
    clearBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -50, -12)
    clearBtn:SetText("Clear")
    clearBtn:SetScript("OnClick", function()
        if RoleCall and RoleCall.ClearAll then
            RoleCall:ClearAll()
            UI:Refresh()
            if Core and Core.DebugPrint then
                Core:DebugPrint("Board cleared manually.")
            end
        end
    end)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() UI:Hide() end)
    
    -- Resize grip
    local resizeBtn = CreateFrame("Button", nil, frame)
    resizeBtn:SetSize(20, 20)
    resizeBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)
    resizeBtn:EnableMouse(true)
    resizeBtn:SetFrameLevel(frame:GetFrameLevel() + 10)
    
    -- Create visible texture for resize grip
    local resizeTex = resizeBtn:CreateTexture(nil, "ARTWORK")
    resizeTex:SetAllPoints()
    resizeTex:SetColorTexture(0.5, 0.5, 0.5, 0.8)  -- Gray square for visibility
    
    -- Add diagonal lines to indicate resize
    local line1 = resizeBtn:CreateTexture(nil, "OVERLAY")
    line1:SetColorTexture(0.8, 0.8, 0.8, 1)
    line1:SetSize(2, 14)
    line1:SetPoint("BOTTOMLEFT", resizeBtn, "BOTTOMLEFT", 4, 4)
    line1:SetRotation(math.rad(45))
    
    resizeBtn:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frame:StartSizing("BOTTOM")
        end
    end)
    resizeBtn:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
        end
    end)
    resizeBtn:SetScript("OnEnter", function(self)
        resizeTex:SetColorTexture(0.7, 0.7, 0.7, 1)
    end)
    resizeBtn:SetScript("OnLeave", function(self)
        resizeTex:SetColorTexture(0.5, 0.5, 0.5, 0.8)
    end)
    
    -- Column headers
    frame.headerTexts = {}
    frame.headerButtons = {}
    
    local columns = self:CalculateColumnLayout(frame:GetWidth())
    
    for i, col in ipairs(columns) do
        local h = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        h:SetPoint("TOPLEFT", frame, "TOPLEFT", col.x, -40)
        h:SetSize(col.width, 20)
        h:SetJustifyH("LEFT")
        h:SetWordWrap(false)
        h:SetText(col.name)
        frame.headerTexts[i] = h
        
        -- Make header clickable for sorting
        local headerBtn = CreateFrame("Button", nil, frame)
        headerBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", col.x - 5, -40)
        headerBtn:SetWidth(col.width)
        headerBtn:SetHeight(20)
        headerBtn:SetScript("OnClick", function()
            local sortCol = string.lower(col.name)
            if sortCol == "role/class" then sortCol = "role" end
            UI:SetSort(sortCol)
        end)
        frame.headerButtons[i] = headerBtn
    end
    
    self.frame = frame
end

-- Update column header positions when frame is resized
function UI:UpdateColumnHeaders()
    if not self.frame then return end
    
    local columns = self:CalculateColumnLayout(self.frame:GetWidth())
    
    for i, col in ipairs(columns) do
        if self.frame.headerTexts[i] then
            self.frame.headerTexts[i]:ClearAllPoints()
            self.frame.headerTexts[i]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", col.x, -40)
            self.frame.headerTexts[i]:SetSize(col.width, 20)
        end
        if self.frame.headerButtons[i] then
            self.frame.headerButtons[i]:ClearAllPoints()
            self.frame.headerButtons[i]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", col.x - 5, -40)
            self.frame.headerButtons[i]:SetWidth(col.width)
        end
    end
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

-- Set sort column and direction, then refresh
function UI:SetSort(column)
    -- Toggle sort direction if clicking same column, otherwise set new column
    if self.sortBy == column then
        self.sortAsc = not self.sortAsc
    else
        self.sortBy = column
        self.sortAsc = false  -- Default to descending for new column
    end
    self:Refresh()
end

-- Sort entries based on current sort settings
function UI:SortEntries(entries)
    local sortBy = self.sortBy
    local sortAsc = self.sortAsc
    
    table.sort(entries, function(a, b)
        local aVal, bVal
        
        if sortBy == "dungeon" then
            aVal = a.dungeon or ""
            bVal = b.dungeon or ""
        elseif sortBy == "role" then
            aVal = a.classes and #a.classes > 0 and table.concat(a.classes, ",") or ""
            bVal = b.classes and #b.classes > 0 and table.concat(b.classes, ",") or ""
        elseif sortBy == "player" then
            aVal = a.player or ""
            bVal = b.player or ""
        elseif sortBy == "level" then
            aVal = a.level or 0
            bVal = b.level or 0
        else  -- "time" or default
            aVal = a.timestamp or 0
            bVal = b.timestamp or 0
        end
        
        if sortAsc then
            return aVal < bVal
        else
            return aVal > bVal
        end
    end)
    
    return entries
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
    
    -- Sort entries
    entries = self:SortEntries(entries)
    
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
    if not self.contentFrame or not self.frame then
        return nil
    end
    
    local columns = self:CalculateColumnLayout(self.frame:GetWidth())
    
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
        text:SetWordWrap(false)
        return text
    end
    
    row.dungeon = CreateColumnText(columns[1].x, columns[1].width)
    row.roles = CreateColumnText(columns[2].x, columns[2].width)
    row.player = CreateColumnText(columns[3].x, columns[3].width)
    row.level = CreateColumnText(columns[4].x, columns[4].width)
    row.time = CreateColumnText(columns[5].x, columns[5].width)
    
    -- Populate text
    local displayName = entry.dungeon
    if Parser and entry.dungeon ~= "?" then
        displayName = Parser:GetDungeonDisplayName(entry.dungeon)
    end
    row.dungeon:SetText(displayName or "?")
    
    -- Highlight context-only entries (no specific dungeon)
    if entry.dungeon == "?" then
        row.dungeon:SetTextColor(0.7, 0.7, 0.7)  -- Gray out uncertain dungeon
    end
    
    -- Format roles
    local roleClassText = ""
    if entry.classes and #entry.classes > 0 then
        roleClassText = table.concat(entry.classes, ", ")
    else
        -- Build from roles
        local roleList = {}
        if entry.roles.tank then table.insert(roleList, "Tank") end
        if entry.roles.healer then table.insert(roleList, "Healer") end
        if entry.roles.dps then table.insert(roleList, "DPS") end
        roleClassText = table.concat(roleList, ", ") or "-"
    end
    row.roles:SetText(roleClassText)
    
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
