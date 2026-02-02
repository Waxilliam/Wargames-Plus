-- 0. Initialization & Saved Variables
-- (Ensure '## SavedVariables: WG_History' is in your .toc file)
WG_History = WG_History or {}

-- 1. Create the Main Window
local frame = CreateFrame("Frame", "WGFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(320, 540) -- Increased height slightly for the new buttons
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame.TitleText:SetText("WarGames+")
frame:Hide()
tinsert(UISpecialFrames, frame:GetName()) -- Allow ESC to close

-- 2. Party Leader Input Box & Label
local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
label:SetPoint("TOPLEFT", 25, -35)
label:SetText("Opponent Party Leader:")

local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
editBox:SetSize(170, 30) -- Smaller to fit buttons next to it
editBox:SetPoint("TOPLEFT", 25, -50)
editBox:SetAutoFocus(false)

-- Target Button: Grabs current target name
local targetBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
targetBtn:SetSize(70, 25)
targetBtn:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
targetBtn:SetText("Target")
targetBtn:SetScript("OnClick", function()
    local name = GetUnitName("target", true)
    if name then editBox:SetText(name) end
end)

-- 3. History Dropdown
local dropdown = CreateFrame("Frame", "WGHistoryDropdown", frame, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOPLEFT", 10, -85)

local function OnHistoryClick(self)
    editBox:SetText(self.value)
    CloseDropDownMenus()
end

UIDropDownMenu_Initialize(dropdown, function(self, level)
    if #WG_History == 0 then
        local info = UIDropDownMenu_CreateInfo()
        info.text = "No History"
        info.notCheckable = true
        info.disabled = true
        UIDropDownMenu_AddButton(info)
        return
    end
    for _, name in ipairs(WG_History) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = name
        info.value = name
        info.func = OnHistoryClick
        info.notCheckable = true
        UIDropDownMenu_AddButton(info)
    end
end)

local dropLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
dropLabel:SetPoint("LEFT", dropdown, "RIGHT", -10, 3)
dropLabel:SetText("Recent Leaders")

-- 4. Arena List
local arenas = {
    "Nagrand Arena",
    "Ruins of Lordaeron",
    "Tiger's Peak",
    "Tol'Viron Arena",
    "Ashamane's Fall",
    "Hook Point",
    "Mugambala",
    "Empyrean Capacity",
    "Black Rook Hold",
    "Nokhudon Proving Grounds"
}

local selectedArena = arenas[1]
local buttons = {}

-- Create Selectable Arena Buttons
for i, arenaName in ipairs(arenas) do
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(270, 25)
    btn:SetPoint("TOP", 0, -125 - (i * 26)) -- Adjusted Y to account for dropdown
    btn:SetText(arenaName)
    
    btn:SetScript("OnClick", function(self)
        selectedArena = arenaName
        for _, b in ipairs(buttons) do b:UnlockHighlight() end
        self:LockHighlight()
    end)
    
    table.insert(buttons, btn)
    if i == 1 then btn:LockHighlight() end
end

-- 5. THE SEND CHALLENGE BUTTON
local challengeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
challengeBtn:SetSize(200, 40)
challengeBtn:SetPoint("BOTTOM", 0, 20)
challengeBtn:SetText("SEND CHALLENGE")
challengeBtn:SetNormalFontObject("GameFontNormalLarge")

-- Link Enter key to the challenge button
editBox:SetScript("OnEnterPressed", function(self)
    challengeBtn:Click()
end)

challengeBtn:SetScript("OnClick", function()
    local leaderName = editBox:GetText():trim()
    
    if leaderName == "" then
        print("|cFFFF0000[WG+]:|r Please enter an opponent name!")
        return
    end

    -- Update History: Remove if exists, then insert at top
    for i, v in ipairs(WG_History) do
        if v == leaderName then table.remove(WG_History, i) break end
    end
    table.insert(WG_History, 1, leaderName)
    if #WG_History > 10 then table.remove(WG_History) end

    local command = "/sswg " .. leaderName .. " " .. selectedArena
    
    local chatBox = ChatEdit_ChooseBoxForSend()
    ChatEdit_ActivateChat(chatBox)
    chatBox:SetText(command)
    ChatEdit_SendText(chatBox)
    
    print("|cFF00FFFF[WG+] Executing:|r " .. command)
end)

-- 6. Slash Command
SLASH_VIBEWG1 = "/wg"
SlashCmdList["VIBEWG"] = function()
    if frame:IsShown() then frame:Hide() else frame:Show() end
end

print("|cFF00FF00WarGames+ loaded. Use /wg to open.|r")

-- 7. Right-Click Menu Integration (UnitPopup)
-- This adds "Challenge" to the right-click menu of friends/guildies
local CHALLENGE_BUTTON_TEXT = "Challenge (WG+)"

-- Function to handle the click from the right-click menu
local function OnChallengeMenuClick(owner)
    local name = owner.name -- The name of the person you right-clicked
    if not name then return end
    
    -- We use your existing selectedArena variable
    local command = "/sswg " .. name .. " " .. selectedArena
    
    local chatBox = ChatEdit_ChooseBoxForSend()
    ChatEdit_ActivateChat(chatBox)
    chatBox:SetText(command)
    ChatEdit_SendText(chatBox)
    
    print("|cFF00FFFF[WG+] Challenging Friend:|r " .. command)
end

-- Hook into the UnitPopup system
hooksecurefunc("UnitPopup_ShowMenu", function(dropdownMenu, which, unit, name)
    -- 'FRIEND' is the menu type for the contact list
    if which == "FRIEND" or which == "CHAT_ROSTER" then
        local info = UIDropDownMenu_CreateInfo()
        info.text = CHALLENGE_BUTTON_TEXT
        info.owner = dropdownMenu
        info.notCheckable = true
        info.func = function() OnChallengeMenuClick(dropdownMenu) end
        UIDropDownMenu_AddButton(info)
    end
end)