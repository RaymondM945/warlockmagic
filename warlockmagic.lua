local isFollowing = nil
local stopaddon = false
local checkfollow = true
local castshadowbolt = true
local castimmolate = true

local MyCheckbox = CreateFrame("CheckButton", "MyCheckboxExample", UIParent, "UICheckButtonTemplate")
MyCheckbox:SetSize(30, 30)

-- Anchor to the top center of the screen
MyCheckbox:SetPoint("TOP", UIParent, "TOP", 0, -20) -- 20 pixels down from the top

MyCheckbox.text = MyCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
MyCheckbox.text:SetPoint("LEFT", MyCheckbox, "RIGHT", 5, 0)
MyCheckbox.text:SetText("stop addon")

MyCheckbox:SetChecked(stopaddon)

MyCheckbox:SetScript("OnClick", function(self)
	if self:GetChecked() then
		print("Checkbox is checked!")
		stopaddon = true
	else
		print("Checkbox is unchecked!")
		stopaddon = false
	end
end)

local MyCheckbox2 = CreateFrame("CheckButton", "MyCheckbox2", UIParent, "UICheckButtonTemplate")
MyCheckbox2:SetSize(30, 30)
MyCheckbox2:SetPoint("TOP", MyCheckbox, "BOTTOM", 0, 0) -- 10 pixels below the first checkbox

MyCheckbox2.text = MyCheckbox2:CreateFontString(nil, "ARTWORK", "GameFontNormal")
MyCheckbox2.text:SetPoint("LEFT", MyCheckbox2, "RIGHT", 5, 0)
MyCheckbox2.text:SetText("Check following")

MyCheckbox2:SetChecked(checkfollow)
MyCheckbox2:SetScript("OnClick", function(self)
	checkfollow = self:GetChecked()
	print("Checkbox 2 is", self:GetChecked() and "checked" or "unchecked")
end)

local MyCheckbox3 = CreateFrame("CheckButton", "MyCheckbox3", UIParent, "UICheckButtonTemplate")
MyCheckbox3:SetSize(30, 30)
MyCheckbox3:SetPoint("TOP", MyCheckbox2, "BOTTOM", 0, 0) -- Directly under Checkbox2

MyCheckbox3.text = MyCheckbox3:CreateFontString(nil, "ARTWORK", "GameFontNormal")
MyCheckbox3.text:SetPoint("LEFT", MyCheckbox3, "RIGHT", 5, 0)
MyCheckbox3.text:SetText("cast immolate")

MyCheckbox3:SetChecked(castshadowbolt)

MyCheckbox3:SetScript("OnClick", function(self)
	castshadowbolt = self:GetChecked()
end)

local MyCheckbox4 = CreateFrame("CheckButton", "MyCheckbox4", UIParent, "UICheckButtonTemplate")
MyCheckbox4:SetSize(30, 30)
MyCheckbox4:SetPoint("TOP", MyCheckbox3, "BOTTOM", 0, 0) -- Directly under Checkbox2

MyCheckbox4.text = MyCheckbox4:CreateFontString(nil, "ARTWORK", "GameFontNormal")
MyCheckbox4.text:SetPoint("LEFT", MyCheckbox4, "RIGHT", 5, 0)
MyCheckbox4.text:SetText("cast shadow bolt")

MyCheckbox4:SetChecked(castimmolate)

MyCheckbox4:SetScript("OnClick", function(self)
	castimmolate = self:GetChecked()
end)

local box = CreateFrame("Frame", "CombatRogueCenterBox", UIParent)
box:SetSize(25, 25)
box:SetPoint("CENTER", UIParent, "CENTER")
box.texture = box:CreateTexture(nil, "BACKGROUND")
box.texture:SetAllPoints()
box.texture:SetColorTexture(0, 0, 0, 1)

local f = CreateFrame("Frame")

f:SetScript("OnUpdate", function(self, elapsed)
	box.texture:SetColorTexture(0, 0, 0, 1)

	if IsInGroup() and not stopaddon then
		local targethealth = UnitHealth("party1target")
		local targetmaxHealth = UnitHealthMax("party1target")
		if targetmaxHealth > 0 then
			hpPercent = (targethealth / targetmaxHealth) * 100
		end

		if UnitAffectingCombat("party1") and hpPercent < 97 then
			box.texture:SetColorTexture(1, 1, 0, 1)

			local corruptionName = GetSpellInfo(172)
			local immolateName = GetSpellInfo(348)
			local curseOfReck = GetSpellInfo(704)
			local sametarget = UnitIsUnit("target", "party1target")
			local spell = UnitCastingInfo("player")

			local sname = "Shadow Bolt"
			local shadowisUsable, notEnoughMana = IsUsableSpell(sname)
			local canCastShadowBolt = shadowisUsable and not notEnoughMana and spell ~= sname

			local healthplayer = UnitHealth("player")
			local maxplayerHealth = UnitHealthMax("player")

			local hpPercentplayer = (healthplayer / maxplayerHealth) * 100

			local start, duration, enable = C_Container.GetContainerItemCooldown(0, 1)

			local canusePotion = start == 0 and duration == 0 and enable == 1

			if canusePotion and hpPercentplayer < 40 then
				box.texture:SetColorTexture(0.5, 0.5, 0.5, 1)
			elseif not sametarget then
				box.texture:SetColorTexture(0, 0, 1, 1)
			elseif not isFollowing and checkfollow then
				box.texture:SetColorTexture(1, 1, 1, 1)
			elseif
				not AuraUtil.FindAuraByName(corruptionName, "target", "HARMFUL") and IsUsableSpell(corruptionName)
			then
				box.texture:SetColorTexture(1, 0, 0, 1)
			elseif
				not AuraUtil.FindAuraByName(immolateName, "target", "HARMFUL")
				and IsUsableSpell(immolateName)
				and (spell ~= immolateName)
				and castimmolate
			then
				box.texture:SetColorTexture(1, 0, 1, 1)
			elseif not AuraUtil.FindAuraByName(curseOfReck, "target", "HARMFUL") and IsUsableSpell(curseOfReck) then
				box.texture:SetColorTexture(0, 1, 1, 1)
			elseif canCastShadowBolt and castshadowbolt then
				box.texture:SetColorTexture(0.5, 1, 0.5, 1)
			elseif not IsAutoRepeatSpell("Shoot") then
				box.texture:SetColorTexture(0, 1, 0, 1)
			end
		else
			local health = UnitHealth("player")
			local maxHealth = UnitHealthMax("player")

			local hpPercent = (health / maxHealth) * 100
			local mana = UnitPower("player", 0)
			local maxMana = UnitPowerMax("player", 0)
			local mppercent = (mana / maxMana) * 100

			if hpPercent > 70 and mppercent < 90 then
				box.texture:SetColorTexture(1, 0.5, 0.5, 1)
			else
				box.texture:SetColorTexture(0, 0, 0, 1)
			end
		end
	end
end)

local function FindItemInBags(targetItemID)
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local itemID = GetContainerItemID(bag, slot)
			if itemID == targetItemID then
				print("Found item in bag " .. bag .. ", slot " .. slot)
				return bag, slot
			end
		end
	end
	print("Item not found in bags.")
	return nil
end

box:RegisterEvent("AUTOFOLLOW_BEGIN")
box:RegisterEvent("AUTOFOLLOW_END")

box:RegisterEvent("PLAYER_LOGIN")

box:SetScript("OnEvent", function(self, event, ...)
	if event == "AUTOFOLLOW_BEGIN" then
		local name = ...
		isFollowing = name
		print("Now following: " .. (name or "unknown"))
	elseif event == "AUTOFOLLOW_END" then
		isFollowing = nil
		print("Stopped following")
	elseif event == "PLAYER_LOGIN" then
		print("Player has logged in. Initializing addon...")
	end
end)
