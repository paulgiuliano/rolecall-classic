-- Minimap.lua
-- Minimap button to show/hide the RoleCall board

local Minimap = {}

-- Saved variables for minimap button position
RoleCallMinimapDB = RoleCallMinimapDB or {
    hide = false,
    minimapPos = 220,
    radius = 80,
}

-- Create the minimap button
function Minimap:Initialize()
    if self.button then
        return -- Already created
    end
    
    -- Create the button frame
    local button = CreateFrame("Button", "RoleCallMinimapButton", Minimap, "BackdropTemplate")
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    -- Create icon texture
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")  -- Scroll icon
    button.icon = icon
    
    -- Create overlay (the circular border)
    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetPoint("TOPLEFT", 0, 0)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.overlay = overlay
    
    -- Create border frame
    local border = button:CreateTexture(nil, "ARTWORK")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\Minimap-TrackingBorder")
    button.border = border
    
    -- Click handler
    button:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            -- Toggle the RoleCall board
            if UI and UI.Toggle then
                UI:Toggle()
            end
        elseif button == "RightButton" then
            -- Show options menu (future enhancement)
            -- For now, just toggle notifications
            if Core and Core.ToggleNotifications then
                local enabled = Core:ToggleNotifications()
                if Core.DebugPrint then
                    Core:DebugPrint("Notifications " .. (enabled and "enabled" or "disabled"))
                end
            end
        end
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("RoleCall Classic", 1, 1, 1)
        GameTooltip:AddLine("Left-click to toggle board", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Right-click to toggle notifications", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Drag to move", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- Dragging functionality
    button:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self.isMoving = true
        self:SetScript("OnUpdate", function(self)
            Minimap:UpdatePosition()
        end)
    end)
    
    button:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self.isMoving = false
        self:SetScript("OnUpdate", nil)
    end)
    
    self.button = button
    self:UpdatePosition()
    
    -- Show or hide based on saved settings
    if RoleCallMinimapDB.hide then
        button:Hide()
    else
        button:Show()
    end
end

-- Update button position around the minimap
function Minimap:UpdatePosition()
    if not self.button then return end
    
    local button = self.button
    local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local radius = RoleCallMinimapDB.radius or 80
    
    if button.isMoving then
        -- Calculate angle based on mouse position
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        
        local angle = math.atan2(py - my, px - mx)
        RoleCallMinimapDB.minimapPos = math.deg(angle)
    end
    
    local angle = math.rad(RoleCallMinimapDB.minimapPos or 220)
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Show the minimap button
function Minimap:Show()
    if self.button then
        self.button:Show()
        RoleCallMinimapDB.hide = false
    end
end

-- Hide the minimap button
function Minimap:Hide()
    if self.button then
        self.button:Hide()
        RoleCallMinimapDB.hide = true
    end
end

-- Toggle minimap button visibility
function Minimap:Toggle()
    if self.button then
        if self.button:IsShown() then
            self:Hide()
        else
            self:Show()
        end
    end
end

_G.MinimapButton = Minimap
