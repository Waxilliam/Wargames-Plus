-- core.lua: WarGames+ 
local ADDON_NAME = ...

-- 0. Database Safety
WG_History = WG_History or {}
if not WG_History.favorites then WG_History.favorites = {} end
if not WG_History.opponents then WG_History.opponents = {} end
if not WG_History.theme then WG_History.theme = "Horde" end
if WG_History.minimapAngle == nil then WG_History.minimapAngle = 225 end

-- ---------- 1. DATA & STYLES ----------
local ARENA_LIST = {
    "Random Map",
    "Nagrand Arena", "Blade's Edge Arena", "Ruins of Lordaeron", "Dalaran Arena",
    "Ring of Valor", "Tol'viron Arena", "Tiger's Peak", "Ashamane's Fall",
    "Black Rook Hold Arena", "Hook Point", "Mugambala", "Maldraxxus Coliseum",
    "Nokhudon Proving Grounds"
}

local BG_LIST = {
    "Random Map",
    "Warsong Gulch", "Twin Peaks", "Arathi Basin", "The Battle for Gilneas",
    "Eye of the Storm", "Temple of Kotmogu", "Silvershard Mines", 
    "Seething Shore", "Deephaul Ravine"
}

local MAP_TEXTURES = {
    -- 1. MODERN MAPS (Using Widescreen File IDs to prevent green boxes)
    ["Nokhudon Proving Grounds"] = "Interface\\AddOns\\Wargames\\media\\maps\\Nokhudon.tga", -- Wide
    ["Maldraxxus Coliseum"]      = "Interface\\AddOns\\Wargames\\media\\maps\\Maldraxxus.tga", -- Wide
    ["Mugambala"]                = "Interface\\AddOns\\Wargames\\media\\maps\\Mugambala.tga", -- Wide
    ["Hook Point"]               = "Interface\\AddOns\\Wargames\\media\\maps\\Hookpoint.tga", -- Wide
    ["Tiger's Peak"]             = "Interface\\AddOns\\Wargames\\media\\maps\\Tigerspeek.tga",  -- Wide
    ["Seething Shore"]           = "Interface\\AddOns\\Wargames\\media\\maps\\Seething.tga", -- Wide
    ["Ashamane's Fall"]          = "Interface\\AddOns\\Wargames\\media\\maps\\Ashamanes.tga", -- (Standard usually works, but this is the ID)
    ["Black Rook Hold Arena"]    = "Interface\\AddOns\\Wargames\\media\\maps\\Blackrook.tga", -- (Standard)
    
    -- 2. SPECIAL CASES (Internal names differ from map names)
    ["Ring of Valor"]            = "Interface\\AddOns\\Wargames\\media\\maps\\Ring.tga",  -- "Orgrimmar Arena"
    ["Deephaul Ravine"]          = "Interface\\AddOns\\Wargames\\media\\maps\\Deephaul.tga", -- TWW Map (Try this ID, or 5924295 for Wide)

    -- 3. CLASSIC MAPS (Text paths still work reliably for these)
    ["Nagrand Arena"]           = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenNagrandArenaBattlegrounds",
    ["Blade's Edge Arena"]      = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenBladesEdgeArena",
    ["Ruins of Lordaeron"]      = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenRuinsofLordaeronBattlegrounds",
    ["Dalaran Arena"]           = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenDalaranSewersArena",
    ["Tol'viron Arena"]         = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenTolvirArena",
    
    -- 4. BATTLEGROUNDS
    ["Warsong Gulch"]           = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenWarsongGulch",
    ["Twin Peaks"]              = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenTwinPeaksBG",
    ["Arathi Basin"]            = "Interface\\GLUES\\LOADINGSCREENS\\LoadscreenArathiBasin",
    ["The Battle for Gilneas"]  = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenGilneasBG2",
    ["Eye of the Storm"]        = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenNetherBattlegrounds",
    ["Temple of Kotmogu"]       = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenValleyofPower",
    ["Silvershard Mines"]       = "Interface\\GLUES\\LOADINGSCREENS\\LoadScreenSilvershardMines",
}

local THEMES = {
    Midnight = {
        backdropBg      = {0.04, 0.04, 0.06, 0.95},
        backdropBorder  = {0.15, 0.15, 0.20, 1},
        accent          = {0.00, 0.85, 1.00, 1},
        buttonNormal    = {0.10, 0.10, 0.14, 1},
        buttonHover     = {0.18, 0.18, 0.24, 1},
        buttonPushed    = {0.06, 0.06, 0.08, 1},
        buttonBorder    = {0.25, 0.25, 0.30, 1},
        buttonText      = {0.90, 0.90, 0.95, 1},
        buttonDisabled  = {0.40, 0.40, 0.45, 1},
        selectionDim    = {0, 0.6, 1, 0.3},
        selectionFaint  = {0, 0.6, 1, 0.05},
        inputBg         = {0.06, 0.06, 0.08, 0.9},
        inputBorder     = {0.20, 0.20, 0.25, 1},
        inputText       = {0.90, 0.90, 0.95, 1},
        scrollThumb     = {0.30, 0.30, 0.40, 0.8},
        scrollTrack     = {0.08, 0.08, 0.10, 0.5},
        titleColor      = {0.00, 0.85, 1.00, 1},
        headerColor     = {0.70, 0.70, 0.75, 1},
        normalText      = {0.80, 0.80, 0.85, 1},
        footerColor     = {0.50, 0.50, 0.55, 1},
        closeNormal     = {0.60, 0.60, 0.65, 1},
        closeHover      = {1.00, 0.30, 0.30, 1},
        rowHighlight    = {1, 1, 1, 0.08},
        inlineAccent    = "00d8ff",
        inlineGreen     = "00ff00",
        inlineChar      = "ffd100",
        inlineBnet      = "0070ff",
        swatchColor     = {0.00, 0.85, 1.00},
    },
    Horde = {
        backdropBg      = {0.06, 0.04, 0.04, 0.95},
        backdropBorder  = {0.35, 0.10, 0.10, 1},
        accent          = {0.90, 0.15, 0.15, 1},
        buttonNormal    = {0.14, 0.08, 0.08, 1},
        buttonHover     = {0.25, 0.10, 0.10, 1},
        buttonPushed    = {0.08, 0.04, 0.04, 1},
        buttonBorder    = {0.40, 0.12, 0.12, 1},
        buttonText      = {0.95, 0.85, 0.85, 1},
        buttonDisabled  = {0.50, 0.35, 0.35, 1},
        selectionDim    = {0.9, 0.15, 0.15, 0.3},
        selectionFaint  = {0.9, 0.15, 0.15, 0.05},
        inputBg         = {0.08, 0.05, 0.05, 0.9},
        inputBorder     = {0.35, 0.12, 0.12, 1},
        inputText       = {0.95, 0.85, 0.85, 1},
        scrollThumb     = {0.45, 0.15, 0.15, 0.8},
        scrollTrack     = {0.10, 0.06, 0.06, 0.5},
        titleColor      = {0.90, 0.15, 0.15, 1},
        headerColor     = {0.75, 0.60, 0.55, 1},
        normalText      = {0.85, 0.75, 0.75, 1},
        footerColor     = {0.55, 0.40, 0.40, 1},
        closeNormal     = {0.65, 0.50, 0.50, 1},
        closeHover      = {1.00, 0.30, 0.30, 1},
        rowHighlight    = {1, 0.8, 0.8, 0.08},
        inlineAccent    = "e62828",
        inlineGreen     = "66cc44",
        inlineChar      = "ffaa66",
        inlineBnet      = "cc4444",
        swatchColor     = {0.90, 0.15, 0.15},
    },
    Alliance = {
        backdropBg      = {0.04, 0.04, 0.08, 0.95},
        backdropBorder  = {0.65, 0.55, 0.20, 1},
        accent          = {0.25, 0.45, 0.85, 1},
        buttonNormal    = {0.08, 0.08, 0.14, 1},
        buttonHover     = {0.12, 0.14, 0.25, 1},
        buttonPushed    = {0.05, 0.05, 0.08, 1},
        buttonBorder    = {0.55, 0.45, 0.18, 1},
        buttonText      = {0.90, 0.90, 0.95, 1},
        buttonDisabled  = {0.45, 0.45, 0.50, 1},
        selectionDim    = {0.25, 0.45, 0.85, 0.3},
        selectionFaint  = {0.25, 0.45, 0.85, 0.05},
        inputBg         = {0.06, 0.06, 0.10, 0.9},
        inputBorder     = {0.55, 0.45, 0.18, 1},
        inputText       = {0.90, 0.90, 0.95, 1},
        scrollThumb     = {0.40, 0.35, 0.15, 0.8},
        scrollTrack     = {0.06, 0.06, 0.10, 0.5},
        titleColor      = {0.75, 0.65, 0.20, 1},
        headerColor     = {0.65, 0.60, 0.50, 1},
        normalText      = {0.80, 0.80, 0.85, 1},
        footerColor     = {0.50, 0.48, 0.40, 1},
        closeNormal     = {0.60, 0.55, 0.45, 1},
        closeHover      = {1.00, 0.30, 0.30, 1},
        rowHighlight    = {0.9, 0.85, 0.6, 0.08},
        inlineAccent    = "4070d8",
        inlineGreen     = "88cc44",
        inlineChar      = "ddb830",
        inlineBnet      = "4070d8",
        swatchColor     = {0.75, 0.65, 0.20},
    },
}

local activeTheme = THEMES[WG_History.theme] or THEMES.Horde

-- CRITICAL: Define F here so it is visible to ApplyTheme
local F = CreateFrame("Frame", "WG_CoreFrame", UIParent)
local CreateUI -- Forward declaration so MinimapButton can see it
-- ---------- FRAME REGISTRIES ----------
local themedBackdrops = {}
local themedButtons = {}
local themedInputs = {}
local themedElements = {} -- {frame, applyFn}

local FLAT_BACKDROP = {
    bgFile = "Interface/ChatFrame/ChatFrameBackground",
    edgeFile = "Interface/ChatFrame/ChatFrameBackground",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
}

local function ApplyModernStyle(frame)
    if not frame.SetBackdrop then Mixin(frame, BackdropTemplateMixin) end
    frame:SetBackdrop(FLAT_BACKDROP)
    frame:SetBackdropColor(unpack(activeTheme.backdropBg))
    frame:SetBackdropBorderColor(unpack(activeTheme.backdropBorder))
    if not tContains(themedBackdrops, frame) then table.insert(themedBackdrops, frame) end
end

local function StyleButton(btn)
    if not btn._texturesHidden then
        for _, region in pairs({btn:GetRegions()}) do
            if region.GetObjectType and region:GetObjectType() == "Texture" then
                local layer = region:GetDrawLayer()
                if layer == "BACKGROUND" or layer == "BORDER" then
                    region:SetTexture(nil); region:Hide()
                end
            end
        end
        btn._texturesHidden = true
    end

    if not btn._flatBg then
        btn._flatBg = btn:CreateTexture(nil, "BACKGROUND")
        btn._flatBg:SetAllPoints()
    end
    btn._flatBg:SetColorTexture(unpack(activeTheme.buttonNormal))

    if not btn.SetBackdrop then Mixin(btn, BackdropTemplateMixin) end
    btn:SetBackdrop(FLAT_BACKDROP)
    btn:SetBackdropColor(0, 0, 0, 0) 
    btn:SetBackdropBorderColor(unpack(activeTheme.buttonBorder))

    local fs = btn:GetFontString()
    if fs then
        if not btn._hasInlineColor then
            fs:SetTextColor(unpack(activeTheme.buttonText))
        end
        fs:ClearAllPoints()
        fs:SetPoint("LEFT", btn, "LEFT", 5, 0)
        fs:SetPoint("RIGHT", btn, "RIGHT", -5, 0)
        fs:SetWordWrap(false)
    end

    if not btn._hooksSet then
        btn:HookScript("OnEnter", function(self)
            if self._flatBg then self._flatBg:SetColorTexture(unpack(activeTheme.buttonHover)) end
        end)
        btn:HookScript("OnLeave", function(self)
            if self._flatBg then self._flatBg:SetColorTexture(unpack(activeTheme.buttonNormal)) end
        end)
        btn:HookScript("OnMouseDown", function(self)
            if self._flatBg then self._flatBg:SetColorTexture(unpack(activeTheme.buttonPushed)) end
        end)
        btn:HookScript("OnMouseUp", function(self)
            if self._flatBg then self._flatBg:SetColorTexture(unpack(activeTheme.buttonHover)) end
        end)
        btn._hooksSet = true
    end

    if not tContains(themedButtons, btn) then table.insert(themedButtons, btn) end
end

local function StyleInput(editbox)
    if not editbox._texturesHidden then
        for _, region in pairs({editbox:GetRegions()}) do
            if region.GetObjectType and region:GetObjectType() == "Texture" then
                region:SetTexture(nil); region:Hide()
            end
        end
        editbox._texturesHidden = true
    end

    if not editbox.SetBackdrop then Mixin(editbox, BackdropTemplateMixin) end
    editbox:SetBackdrop(FLAT_BACKDROP)
    editbox:SetBackdropColor(unpack(activeTheme.inputBg))
    editbox:SetBackdropBorderColor(unpack(activeTheme.inputBorder))
    editbox:SetTextColor(unpack(activeTheme.inputText))
    editbox:SetTextInsets(6, 6, 0, 0)

    if not tContains(themedInputs, editbox) then table.insert(themedInputs, editbox) end
end

local function StyleScrollBar(scrollFrame)
    local barName = scrollFrame:GetName() and (scrollFrame:GetName() .. "ScrollBar")
    local bar = barName and _G[barName]
    if not bar or bar._styled then return end

    local up = _G[barName .. "ScrollUpButton"]
    local down = _G[barName .. "ScrollDownButton"]
    if up then up:SetAlpha(0); up:SetSize(1, 1) end
    if down then down:SetAlpha(0); down:SetSize(1, 1) end

    for _, region in pairs({bar:GetRegions()}) do
        if region.GetObjectType and region:GetObjectType() == "Texture" then
            region:SetTexture(nil); region:Hide()
        end
    end

    bar:SetWidth(6)
    if not bar._track then
        bar._track = bar:CreateTexture(nil, "BACKGROUND")
        bar._track:SetAllPoints()
    end
    bar._track:SetColorTexture(unpack(activeTheme.scrollTrack))

    local thumb = _G[barName .. "ThumbTexture"]
    if thumb then
        thumb:SetColorTexture(unpack(activeTheme.scrollThumb))
        thumb:SetSize(6, 30)
    end

    bar._styled = true
    table.insert(themedElements, {bar, function(b)
        if b._track then b._track:SetColorTexture(unpack(activeTheme.scrollTrack)) end
        local t = _G[barName .. "ThumbTexture"]
        if t then t:SetColorTexture(unpack(activeTheme.scrollThumb)) end
    end})
end

local function ApplyTheme(themeName)
    local theme = THEMES[themeName]
    if not theme then themeName = "Horde"; theme = THEMES.Horde end
    activeTheme = theme
    WG_History.theme = themeName

    for _, frame in ipairs(themedBackdrops) do
        frame:SetBackdropColor(unpack(activeTheme.backdropBg))
        frame:SetBackdropBorderColor(unpack(activeTheme.backdropBorder))
    end
    for _, btn in ipairs(themedButtons) do
        if btn._flatBg then btn._flatBg:SetColorTexture(unpack(activeTheme.buttonNormal)) end
        btn:SetBackdropBorderColor(unpack(activeTheme.buttonBorder))
        local fs = btn:GetFontString()
        if fs and not btn._hasInlineColor then fs:SetTextColor(unpack(activeTheme.buttonText)) end
    end
    for _, eb in ipairs(themedInputs) do
        eb:SetBackdropColor(unpack(activeTheme.inputBg))
        eb:SetBackdropBorderColor(unpack(activeTheme.inputBorder))
        eb:SetTextColor(unpack(activeTheme.inputText))
    end
    for _, entry in ipairs(themedElements) do
        local frame, fn = entry[1], entry[2]
        if fn then fn(frame) end
    end

    if F.ui then
        F.ui:Refresh()
        F.ui:RefreshMaps()
        if F.ui.themeDropdown then
            UIDropDownMenu_SetText(F.ui.themeDropdown, themeName)
        end
    end
end

local function GetFormattedName(name, realm)
    if not name or name == "" then return nil end
    if realm and realm ~= "" then return name .. "-" .. realm:gsub("%s+", "") end
    return name
end

local function CreateMinimapButton()
    if F.minimapBtn then return end
    if WG_History.minimapAngle == nil then WG_History.minimapAngle = 225 end

    -- 1. THE BUTTON (Hitbox)
    local btn = CreateFrame("Button", "WG_MinimapButton", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:EnableMouse(true)
    btn:SetMovable(true)
    btn:RegisterForDrag("LeftButton")
    btn:RegisterForClicks("LeftButtonUp")

    -- 2. BACKGROUND (Black circle behind icon)
   -- local bg = btn:CreateTexture(nil, "BACKGROUND")
    --bg:SetSize(20, 20)
   -- border:SetPoint("TOPLEFT", -10, 10)  -- Nudged up slightly
   -- bg:SetColorTexture(0, 0, 0, 0.6)

    -- 3. YOUR CUSTOM ICON
    -- We reduce size to 20x20 so it fits INSIDE the ring without touching edges
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", btn, "TOPLEFT", 3, -2)
    icon:SetTexture("Interface\\AddOns\\Wargames\\media\\wglogo.tga")

    -- 4. BORDER OVERLAY (The metal ring)
    -- This specific texture is designed to be anchored TOPLEFT, not CENTER
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT", -10, 10) -- "Magic numbers" to center the ring over the button
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    -- 5. POSITION LOGIC (Unchanged)
    local function UpdatePosition(angle)
        local rad = math.rad(angle)
        local x = math.cos(rad) * 80
        local y = math.sin(rad) * 80
        btn:ClearAllPoints()
        btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    UpdatePosition(WG_History.minimapAngle)

    -- 6. SCRIPTS (Drag/Click)
    btn:SetScript("OnDragStart", function(self)
        self._dragging = true
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            local angle = math.deg(math.atan2(cy - my, cx - mx))
            WG_History.minimapAngle = angle
            UpdatePosition(angle)
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self._dragging = false
        self:SetScript("OnUpdate", nil)
    end)

    btn:SetScript("OnClick", function()
        if CreateUI then CreateUI() end -- Safe call
        if F.ui then 
            if F.ui:IsShown() then F.ui:Hide() else F.ui:Show(); F.ui:Refresh(); F.ui:UpdateTabDisplay() end
        end
    end)
    
    -- Tooltip
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("WarGames+")
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    F.minimapBtn = btn
end

F:RegisterEvent("ADDON_LOADED")
F:RegisterEvent("PLAYER_LOGIN")

-- ---------- 2. CONTEXT MENU ----------
local function OpenWarGamesMenu(owner, friendData)
    if not friendData then return end
    
    local charName = GetFormattedName(friendData.targetName, friendData.realm) or friendData.targetName
    local title = charName or friendData.battleTag

    MenuUtil.CreateContextMenu(owner, function(owner, rootDescription)
        rootDescription:CreateTitle("|cff" .. activeTheme.inlineAccent .. title .. "|r")
        
        if charName then
            rootDescription:CreateButton("Whisper Character", function() ChatFrame_OpenChat("/w " .. charName .. " ") end)
            rootDescription:CreateButton("Invite Character", function() C_PartyInfo.InviteUnit(charName) end)
        end
        
        rootDescription:CreateDivider()
        
        if charName then
            rootDescription:CreateButton("Challenge Character", function()
                if F.ui then 
                    F.ui.editBox:SetText(charName)
                    F.ui.challengeBtn:Click() 
                end
            end)
        end

        if friendData.battleTag then
            rootDescription:CreateButton("|cff" .. activeTheme.inlineAccent .. "Challenge BTag|r", function()
                if F.ui then
                    F.ui.editBox:SetText(friendData.battleTag)
                    F.ui.challengeBTagBtn:Click()
                end
            end)
        end
    end)
end

-- ---------- 3. UI CONSTRUCTION ----------
CreateUI = function()
    if F.ui then return end

    local ui = CreateFrame("Frame", "WarGamesPlusUI", UIParent)
    ui:SetSize(850, 580)
    ui:SetPoint("CENTER")
    ui:SetMovable(true)
    ui:EnableMouse(true)
    ui:SetFrameStrata("HIGH")
    ui:RegisterForDrag("LeftButton")
    ui:SetScript("OnDragStart", ui.StartMoving)
    ui:SetScript("OnDragStop", ui.StopMovingOrSizing)
    ApplyModernStyle(ui)

    ui.TitleText = ui:CreateFontString(nil, "OVERLAY")
    ui.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    ui.TitleText:SetPoint("TOPLEFT", 20, -15)
    ui.TitleText:SetText("WARGAMES+")
    ui.TitleText:SetTextColor(unpack(activeTheme.titleColor))
    table.insert(themedElements, {ui.TitleText, function(fs) fs:SetTextColor(unpack(activeTheme.titleColor)) end})

    local footer = ui:CreateFontString(nil, "OVERLAY")
    footer:SetFont("Fonts\\FRIZQT__.TTF", 9)
    footer:SetPoint("BOTTOMRIGHT", -20, 15)
    footer:SetText("By Waxology")
    footer:SetTextColor(unpack(activeTheme.footerColor))
    table.insert(themedElements, {footer, function(fs) fs:SetTextColor(unpack(activeTheme.footerColor)) end})

    local close = CreateFrame("Button", nil, ui)
    close:SetSize(20, 20)
    close:SetPoint("TOPRIGHT", -10, -10)
    close.label = close:CreateFontString(nil, "OVERLAY")
    close.label:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    close.label:SetPoint("CENTER", 0, 0)
    close.label:SetText("X")
    close.label:SetTextColor(unpack(activeTheme.closeNormal))
    close:SetScript("OnClick", function() ui:Hide() end)
    close:HookScript("OnEnter", function() close.label:SetTextColor(unpack(activeTheme.closeHover)) end)
    close:HookScript("OnLeave", function() close.label:SetTextColor(unpack(activeTheme.closeNormal)) end)
    table.insert(themedElements, {close, function(c) c.label:SetTextColor(unpack(activeTheme.closeNormal)) end})

    -- --- SOCIAL PANEL ---
    local leftPanel = CreateFrame("Frame", nil, ui)
    leftPanel:SetSize(380, 480) 
    leftPanel:SetPoint("TOPLEFT", 15, -75)
    ui.leftPanel = leftPanel
    ApplyModernStyle(leftPanel) 

    local refreshBtn = CreateFrame("Button", nil, leftPanel, "UIPanelButtonTemplate")
    refreshBtn:SetSize(70, 24)
    refreshBtn:SetPoint("BOTTOMRIGHT", -5, 5) 
    refreshBtn:SetText("Refresh")
    refreshBtn:SetScript("OnClick", function()
        C_FriendList.ShowFriends()
        ui:Refresh()
    end)
    StyleButton(refreshBtn)

    local searchBox = CreateFrame("EditBox", nil, leftPanel, "InputBoxTemplate")
    searchBox:SetSize(110, 24) 
    searchBox:SetPoint("BOTTOMLEFT", 5, 5) 
    searchBox:SetPoint("RIGHT", refreshBtn, "LEFT", -20, 0) 
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function(self)
        ui.filterText = self:GetText()
        ui:Refresh()
    end)
    StyleInput(searchBox)

    local scrollFrame = CreateFrame("ScrollFrame", "WG_RosterScroll", leftPanel, "FauxScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 35) 

    ui.rows = {}
    for i = 1, 15 do
        local row = CreateFrame("Button", nil, leftPanel)
        row:SetSize(350, 30) 
        row:SetPoint("TOPLEFT", 5, -5 - ((i-1)*30))

        local hlTex = row:CreateTexture(nil, "HIGHLIGHT")
        hlTex:SetAllPoints()
        hlTex:SetColorTexture(unpack(activeTheme.rowHighlight))
        row._hlTex = hlTex
        table.insert(themedElements, {row, function(r) r._hlTex:SetColorTexture(unpack(activeTheme.rowHighlight)) end})

        row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.nameText:SetPoint("LEFT", 10, 0)
        
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetScript("OnClick", function(self, button) 
            if not self.friend then return end
            
            local charName = GetFormattedName(self.friend.targetName, self.friend.realm) or self.friend.targetName
            local bTag = self.friend.battleTag
            
            if button == "RightButton" then 
                OpenWarGamesMenu(self, self.friend)
            else 
                if bTag then ui.editBox:SetText(bTag)
                elseif charName then ui.editBox:SetText(charName) end
                PlaySound(856) 
            end
        end)
        ui.rows[i] = row
    end

    -- --- THEME DROPDOWN & LABEL ---
    local themeDrop = CreateFrame("Frame", "WG_ThemeDropdown", ui, "UIDropDownMenuTemplate")
    themeDrop:SetPoint("TOPRIGHT", close, "TOPLEFT", -10, 2)
    UIDropDownMenu_SetWidth(themeDrop, 90)
    ui.themeDropdown = themeDrop
    UIDropDownMenu_SetText(themeDrop, WG_History.theme or "Horde")

    ui.themeLabel = themeDrop:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ui.themeLabel:SetText("Theme:")
    ui.themeLabel:SetPoint("RIGHT", themeDrop, "LEFT", 0, 3) 
    ui.themeLabel:SetTextColor(unpack(activeTheme.normalText))
    table.insert(themedElements, {ui.themeLabel, function(fs) fs:SetTextColor(unpack(activeTheme.normalText)) end})

    UIDropDownMenu_Initialize(themeDrop, function(self, level)
        local sortedThemes = {"Midnight", "Horde", "Alliance"}
        for _, name in ipairs(sortedThemes) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.func = function() ApplyTheme(name); CloseDropDownMenus() end
            info.checked = (WG_History.theme == name)
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- --- COLLAPSE BUTTON ---
    local collapseBtn = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
    collapseBtn:SetSize(80, 22)
    -- Initial Position: Expanded (Next to Title)
    collapseBtn:SetPoint("TOPLEFT", 150, -15)
    collapseBtn:SetText("Collapse")
    ui.isCollapsed = false
    StyleButton(collapseBtn)

    collapseBtn:SetScript("OnClick", function()
        if ui.isCollapsed then
            -- EXPAND
            ui:SetWidth(850)
            ui.leftPanel:Show()
            ui.wgBox:SetPoint("TOPLEFT", 410, -75)
            collapseBtn:SetText("Collapse")
            -- Position: Next to Title (Row 1)
            collapseBtn:ClearAllPoints()
            collapseBtn:SetPoint("TOPLEFT", 150, -15)
        else
            -- COLLAPSE
            ui:SetWidth(430)
            ui.leftPanel:Hide()
            ui.wgBox:SetPoint("TOPLEFT", 15, -75)
            collapseBtn:SetText("Expand")
            -- Position: Below Title (Row 2) to prevent clipping
            collapseBtn:ClearAllPoints()
            collapseBtn:SetPoint("TOPLEFT", 20, -45)
        end
        if ui.mapPreview then ui.mapPreview:Hide() end
        ui.isCollapsed = not ui.isCollapsed
    end)

    -- --- SETTINGS PANEL ---
    local wgBox = CreateFrame("Frame", nil, ui)
    wgBox:SetPoint("TOPLEFT", 410, -75) 
    wgBox:SetPoint("BOTTOMRIGHT", -20, 40)
    ApplyModernStyle(wgBox)
    ui.wgBox = wgBox

    local editBox = CreateFrame("EditBox", nil, wgBox, "InputBoxTemplate")
    editBox:SetSize(240, 30) 
    editBox:SetPoint("TOP", -40, -25)
    editBox:SetAutoFocus(false)
    ui.editBox = editBox
    StyleInput(editBox)

    local targetBtn = CreateFrame("Button", nil, wgBox, "UIPanelButtonTemplate")
    targetBtn:SetSize(70, 25)
    targetBtn:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
    targetBtn:SetText("Target")
    targetBtn:SetScript("OnClick", function()
        local name, realm = GetUnitName("target", true)
        local fullName = GetFormattedName(name, realm)
        if fullName then editBox:SetText(fullName) end
    end)
    StyleButton(targetBtn)

    local dropdown = CreateFrame("Frame", "WG_HistoryDrop", wgBox, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOP", -5, -70)
    UIDropDownMenu_SetWidth(dropdown, 240)
    UIDropDownMenu_SetText(dropdown, "Recent Opponents")
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for _, name in ipairs(WG_History.opponents or {}) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.notCheckable = true
            info.func = function() ui.editBox:SetText(name); CloseDropDownMenus() end
            UIDropDownMenu_AddButton(info)
        end
    end)

    ui.mode = "ARENA" 
    
    local function CreateTab(text, mode)
        local btn = CreateFrame("Button", nil, wgBox, "UIPanelButtonTemplate")
        btn:SetSize(160, 25) 
        btn:SetText(text)
        btn:SetScript("OnClick", function(self)
            ui.mode = mode
            ui:UpdateTabDisplay()
            PlaySound(856)
        end)
        StyleButton(btn)
        return btn
    end

    ui.tabArena = CreateTab("Arenas", "ARENA")
    ui.tabArena:SetPoint("RIGHT", wgBox, "TOP", -2, -125)

    ui.tabBG = CreateTab("Battlegrounds", "BG")
    ui.tabBG:SetPoint("LEFT", wgBox, "TOP", 2, -125)

    local radioContainer = CreateFrame("Frame", nil, wgBox)
    radioContainer:SetSize(220, 30) 
    radioContainer:SetPoint("TOP", 0, -160)
    ui.radioContainer = radioContainer

    local typeLabel = radioContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    typeLabel:SetText("Type:")
    typeLabel:SetPoint("LEFT", 0, 0)
    typeLabel:SetTextColor(unpack(activeTheme.normalText))
    table.insert(themedElements, {typeLabel, function(fs) fs:SetTextColor(unpack(activeTheme.normalText)) end})

    ui.matchSize = "3v3"
    local function CreateRadio(text, value, relativeTo)
        local rb = CreateFrame("CheckButton", nil, radioContainer, "UIRadioButtonTemplate")
        rb:SetPoint("LEFT", relativeTo, "RIGHT", 15, 0)
        rb.text = rb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        rb.text:SetPoint("LEFT", rb, "RIGHT", 5, 0)
        rb.text:SetText(text)
        rb.text:SetTextColor(unpack(activeTheme.normalText))
        table.insert(themedElements, {rb.text, function(fs) fs:SetTextColor(unpack(activeTheme.normalText)) end})
        rb:SetScript("OnClick", function()
            ui.matchSize = value
            ui.rb2v2:SetChecked(value == "2v2")
            ui.rb3v3:SetChecked(value == "3v3")
            PlaySound(856)
        end)
        return rb
    end

    ui.rb2v2 = CreateRadio("Normal", "2v2", typeLabel)
    ui.rb3v3 = CreateRadio("3s Shuffle", "3v3", ui.rb2v2.text)
    ui.rb3v3:SetChecked(true)

    local mapScroll = CreateFrame("ScrollFrame", "WG_MapScroll", wgBox, "UIPanelScrollFrameTemplate")
    mapScroll:SetWidth(300) 
    ApplyModernStyle(mapScroll)
    StyleScrollBar(mapScroll)
    local mapContent = CreateFrame("Frame", nil, mapScroll)
    mapContent:SetSize(280, 500)
    mapScroll:SetScrollChild(mapContent)

    -- Map preview tooltip frame
    local mapPreview = CreateFrame("Frame", nil, ui)
    mapPreview:SetSize(300, 190)
    mapPreview:SetFrameStrata("TOOLTIP")
    ApplyModernStyle(mapPreview)

    mapPreview.title = mapPreview:CreateFontString(nil, "OVERLAY")
    mapPreview.title:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    mapPreview.title:SetPoint("TOP", 0, -6)
    mapPreview.title:SetTextColor(unpack(activeTheme.titleColor))
    table.insert(themedElements, {mapPreview.title, function(fs) fs:SetTextColor(unpack(activeTheme.titleColor)) end})

    mapPreview.tex = mapPreview:CreateTexture(nil, "ARTWORK")
    mapPreview.tex:SetPoint("TOPLEFT", 6, -22)
    mapPreview.tex:SetPoint("BOTTOMRIGHT", -6, 6)

    mapPreview:Hide()
    ui.mapPreview = mapPreview

    ui.mapBtns = {}
    ui.selectedArena = ARENA_LIST[1]
    ui.selectedBG = BG_LIST[1]

    function ui:RefreshMaps()
        local currentList = (ui.mode == "ARENA") and ARENA_LIST or BG_LIST
        local currentSelection = (ui.mode == "ARENA") and ui.selectedArena or ui.selectedBG

        mapContent:SetSize(280, #currentList * 28)

        for _, btn in pairs(ui.mapBtns) do btn:Hide() end

        for i, name in ipairs(currentList) do
            local btn = ui.mapBtns[i] or CreateFrame("Button", nil, mapContent)
            btn:SetSize(270, 26) 
            btn:SetPoint("TOP", 0, -((i-1)*27))
            btn:SetNormalFontObject("GameFontHighlightSmall")

            local label
            if name == "Random Map" then
                label = "|cff" .. activeTheme.inlineGreen .. "Random Map|r"
            else
                label = (WG_History.favorites[name] and "|cff" .. activeTheme.inlineAccent .. "★ |r" or "") .. name
            end
            btn:SetText(label)

            btn.bg = btn.bg or btn:CreateTexture(nil, "BACKGROUND")
            btn.bg:SetAllPoints()
            local isSelected = (name == currentSelection)
            local c = isSelected and activeTheme.selectionDim or activeTheme.selectionFaint
            btn.bg:SetColorTexture(unpack(c))

            btn:SetScript("OnClick", function()
                if IsShiftKeyDown() then WG_History.favorites[name] = not WG_History.favorites[name]
                else if ui.mode == "ARENA" then ui.selectedArena = name else ui.selectedBG = name end end
                ui:RefreshMaps()
            end)

            btn:SetScript("OnEnter", function()
                local texPath = MAP_TEXTURES[name]
                if not texPath then return end
                mapPreview.tex:SetTexture(texPath)
                if not mapPreview.tex:GetTexture() then return end
                mapPreview.title:SetText(name)
                mapPreview:ClearAllPoints()
                mapPreview:SetPoint("TOPRIGHT", wgBox, "TOPLEFT", -10, 0)
                mapPreview:Show()
            end)
            btn:SetScript("OnLeave", function()
                mapPreview:Hide()
            end)

            btn:Show()
            ui.mapBtns[i] = btn
        end
    end

    local function SendWarGame()
        local t = editBox:GetText():trim()
        if t ~= "" then
            t = t:gsub("#.*", "")

            for i, v in ipairs(WG_History.opponents or {}) do if v == t then table.remove(WG_History.opponents, i) break end end
            table.insert(WG_History.opponents, 1, t)
            if #WG_History.opponents > 10 then table.remove(WG_History.opponents) end

            local mapName = (ui.mode == "ARENA") and ui.selectedArena or ui.selectedBG
            if mapName == "Random Map" then
                local list = (ui.mode == "ARENA") and ARENA_LIST or BG_LIST
                if #list > 1 then mapName = list[math.random(2, #list)] end
                print("|cff" .. activeTheme.inlineAccent .. "[WG+]|r Randomly selected: " .. mapName)
            end

            local cmd = ""
            if ui.mode == "ARENA" then
                local prefix = (ui.matchSize == "2v2") and "/wg" or "/sswg"
                cmd = ("%s %s %s"):format(prefix, t, mapName)
            else
                cmd = ("/wg %s %s"):format(t, mapName)
            end

            local chatBox = ChatEdit_ChooseBoxForSend()
            if chatBox then
                chatBox:SetText(cmd)
                ChatEdit_SendText(chatBox, 1)
            end
        end
    end

    local challengeBtn = CreateFrame("Button", nil, wgBox, "UIPanelButtonTemplate")
    challengeBtn:SetSize(160, 45)
    challengeBtn:SetPoint("BOTTOMRIGHT", wgBox, "BOTTOM", -5, 15)
    challengeBtn:SetScript("OnClick", function() SendWarGame() end)
    StyleButton(challengeBtn)
    challengeBtn._hasInlineColor = true
    challengeBtn:SetText("|cff" .. activeTheme.inlineAccent .. "Challenge Char|r")
    table.insert(themedElements, {challengeBtn, function(b) b:SetText("|cff" .. activeTheme.inlineAccent .. "Challenge Char|r") end})
    ui.challengeBtn = challengeBtn

    local challengeBTagBtn = CreateFrame("Button", nil, wgBox, "UIPanelButtonTemplate")
    challengeBTagBtn:SetSize(160, 45)
    challengeBTagBtn:SetPoint("BOTTOMLEFT", wgBox, "BOTTOM", 5, 15)
    challengeBTagBtn:SetScript("OnClick", function() SendWarGame() end)
    StyleButton(challengeBTagBtn)
    challengeBTagBtn._hasInlineColor = true
    challengeBTagBtn:SetText("|cff" .. activeTheme.inlineBnet .. "Challenge BTag|r")
    table.insert(themedElements, {challengeBTagBtn, function(b) b:SetText("|cff" .. activeTheme.inlineBnet .. "Challenge BTag|r") end})
    ui.challengeBTagBtn = challengeBTagBtn

    function ui:UpdateTabDisplay()
        if ui.mapPreview then ui.mapPreview:Hide() end
        mapScroll:ClearAllPoints()
        mapScroll:SetWidth(300)
        
        if ui.mode == "ARENA" then
            ui.tabArena:Disable(); ui.tabBG:Enable()
            ui.radioContainer:Show()
            mapScroll:SetPoint("TOP", wgBox, "TOP", 0, -210)
        else
            ui.tabArena:Enable(); ui.tabBG:Disable()
            ui.radioContainer:Hide()
            mapScroll:SetPoint("TOP", wgBox, "TOP", 0, -160)
        end
        
        mapScroll:SetPoint("BOTTOM", wgBox, "BOTTOM", 0, 75)
        ui:RefreshMaps()
    end
    
    function ui:Refresh()
        local charHex = activeTheme.inlineChar
        local bnetHex = activeTheme.inlineBnet
        local data = {}
        for i = 1, (C_FriendList.GetNumFriends() or 0) do
            local info = C_FriendList.GetFriendInfoByIndex(i)
            if info and info.name then
                local r = info.realmName or ""
                local display = info.name .. (r ~= "" and (" - " .. r) or "")
                table.insert(data, { displayName = "|cff"..charHex..display.."|r", targetName = info.name, realm = r, connected = info.connected })
            end
        end
        for i = 1, (BNGetNumFriends() or 0) do
            local acc = C_BattleNet.GetFriendAccountInfo(i)
            if acc and acc.gameAccountInfo then
                local char = acc.gameAccountInfo.characterName
                local r = acc.gameAccountInfo.realmName or ""
                local bTag = acc.battleTag
                if char then
                    local display = "|cff"..bnetHex..(acc.accountName or bTag).."|r (|cff"..charHex..char..(r ~= "" and (" - "..r) or "").."|r)"
                    table.insert(data, { displayName = display, targetName = char, realm = r, battleTag = bTag, connected = acc.gameAccountInfo.isOnline })
                end
            end
        end
        if ui.filterText and ui.filterText ~= "" then
            local f = {}
            local s = ui.filterText:lower()
            for _, d in ipairs(data) do
                local matchName = d.targetName and d.targetName:lower():find(s, 1, true)
                local matchRealm = d.realm and d.realm:lower():find(s, 1, true)
                local matchBTag = d.battleTag and d.battleTag:lower():find(s, 1, true)
                if matchName or matchRealm or matchBTag then 
                    table.insert(f, d) 
                end
            end
            data = f
        end
        table.sort(data, function(a, b) if a.connected ~= b.connected then return a.connected end return a.targetName < b.targetName end)
        FauxScrollFrame_Update(WG_RosterScroll, #data, 15, 30)
        local o = FauxScrollFrame_GetOffset(WG_RosterScroll)
        for i = 1, 15 do
            local r = ui.rows[i]
            local d = data[i+o]
            if d then r:Show(); r.friend = d; r.nameText:SetText(d.displayName) else r:Hide() end
        end
    end

    WG_RosterScroll:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 30, function() ui:Refresh() end) end)
    StyleScrollBar(WG_RosterScroll)

    ui:UpdateTabDisplay(); ui:Hide(); F.ui = ui
end

SLASH_WARGAMESPLUS1 = "/war"
SlashCmdList["WARGAMESPLUS"] = function()
    CreateUI()
    if F.ui:IsShown() then F.ui:Hide() else F.ui:Show(); F.ui:Refresh(); F.ui:UpdateTabDisplay() end
end

F:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_LOGIN" then
        CreateMinimapButton()
        print("WarGames+ Loaded.")
    end
end)