--========--
-- Config --
--========--

-- icon texture
local icon = GetSpellTexture(111771)
-- icon size
local size = 100

--=======--
-- Check --
--=======--

-- check focus exists
local function readyCheck()
	if not UnitExists("focus") then
		RaidNotice_AddMessage(RaidWarningFrame, "未设焦点！", ChatTypeInfo["RAID_WARNING"])
		PlaySound("RaidWarning", "Master")
	end
end

-- check key binding
local function checkBinding()
	local key = GetBindingKey("INTERACTMOUSEOVER")
	if not key then
		print("你尚未绑定<与鼠标悬停处互动>按键！")
	else
		return
	end
end

--========--
-- Button --
--========--

-- creat button
local Tele = CreateFrame("Button", "TeleBuutton", frame, "SecureUnitButtonTemplate BackdropTemplate")
	Tele:SetAttribute("unit", "focus")
	RegisterUnitWatch(Tele)
	
	-- set texture
	Tele:SetSize(size, size)
	Tele:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	Tele:SetFrameStrata("HIGH")
	Tele:SetNormalTexture(icon)
	Tele:GetNormalTexture():SetTexCoord(.92, .08, .92, .08)
	Tele:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		--edgeFile = "Interface\\BUTTONS\\WHITE8X8",
		--tile = true, tileSize = 0,
		--edgeSize = 32,
		insets = { left = -2, right = -2, top = -2, bottom = -2 }
		})
	Tele:SetBackdropColor(0, 1, 1)

	-- set dragable
	Tele:SetMovable(true)
	Tele:SetUserPlaced(true)
	Tele:SetClampedToScreen(true)
	Tele:EnableMouse(true)
	Tele:RegisterForDrag("RightButton")
	Tele:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	Tele:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)

-- set text
local t = Tele:CreateFontString(Tele, "OVERLAY", "GameTooltipText")
	t:SetPoint("BOTTOM", 0, 10)
	t:SetText("")

-- update text
local function updateText()
	local isTeleport
	-- get teleport door npc id
	local GUID = UnitGUID("focus")
	if GUID then
		local npcID = select(6, strsplit("-", GUID))
		if npcID and (npcID == "59271" or npcID == "59262") then
			isTeleport = true
		else
			isTeleport = false
		end
	end
	-- set text
	t:SetText(isTeleport and "鼠标指向我\n再按互动键" or "不是传送门！")
end

-- set default distance type
local rangeFlag = false
-- range check
local function checkDistance(self)
	local inRange = CheckInteractDistance("focus", 2)
	-- distance type match check, to make less color refresh
	if inRange == rangeFlag then return end
	rangeFlag = inRange

	if inRange then
		self:SetBackdropColor(0, 1, 1)
	else
		self:SetBackdropColor(1, 0, 0)
	end
end

-- range check
--[[local function checkDistance(self)
	local inRange = CheckInteractDistance("focus", 5)
	local inRange = IsItemInRange(37727, "focus")	-- 5 yards check take from bw
	if inRange then
		self:SetBackdropColor(0, 1, 1)
	else
		self:SetBackdropColor(1, 0, 0)
	end
end]]--

-- update range check
local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	
	if self.timer > .1 then
		checkDistance(self)
		self.timer = 0
	end
end

-- drag tooltip
local function TeleTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 8)
	GameTooltip:AddDoubleLine(DRAG_MODEL, "Alt + |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t", 0, 1, 0.5, 1, 1, 1)
	GameTooltip:Show()
end

--==========--
-- Register --
--==========--
	
	-- register event
	Tele:RegisterEvent("PLAYER_STARTED_MOVING")
	Tele:RegisterEvent("PLAYER_STOPPED_MOVING")
	Tele:RegisterEvent("PLAYER_ENTERING_WORLD")
	Tele:RegisterEvent("PLAYER_ENTERING_WORLD")
	Tele:RegisterEvent("PLAYER_FOCUS_CHANGED")
	Tele:RegisterEvent("READY_CHECK")
	
	-- trigger event to update
	Tele:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_STARTED_MOVING" then
			self:SetScript("OnUpdate", OnUpdate)
		elseif event == "PLAYER_STOPPED_MOVING" then
			self:SetScript("OnUpdate", nil)
			checkDistance(self)
		elseif event == "PLAYER_ENTERING_WORLD" then
			checkBinding()
		elseif event == "PLAYER_FOCUS_CHANGED" then
			updateText()
			checkDistance(self)
		elseif event == "READY_CHECK" then
			readyCheck()
		end
	end)
	
	-- Show tooltip for drag
	Tele:SetScript("OnEnter", function(self)
		TeleTooltip(self)
	end)
	Tele:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
--=====--
-- CMD --
--=====--

-- drag reset
local function Reset()
	Tele:ClearAllPoints()
	Tele:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

SlashCmdList["RESET"] = function()
	Reset()
end
SLASH_RESETMM1 = "/rtb"
SLASH_RESETMM2 = "/resettb"