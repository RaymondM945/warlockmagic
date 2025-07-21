local isFollowing = nil

local box = CreateFrame("Frame", "CombatRogueCenterBox", UIParent)
box:SetSize(25, 25)
box:SetPoint("CENTER", UIParent, "CENTER")
box.texture = box:CreateTexture(nil, "BACKGROUND")
box.texture:SetAllPoints()
box.texture:SetColorTexture(0, 0, 0, 1)

local f = CreateFrame("Frame")

f:SetScript("OnUpdate", function(self, elapsed)
	box.texture:SetColorTexture(0, 0, 0, 1)

	if IsInGroup() then
		local targethealth = UnitHealth("target")
		local targetmaxHealth = UnitHealthMax("target")
		local hpPercent = (targethealth / targetmaxHealth) * 100
		if UnitAffectingCombat("player") and hpPercent < 95 then
			box.texture:SetColorTexture(1, 1, 0, 1)
			local corruptionName = GetSpellInfo(172)
			local immolateName = GetSpellInfo(348)
			local curseOfReck = GetSpellInfo(704)
			local sametarget = UnitIsUnit("target", "party1target")

			if not sametarget then
				box.texture:SetColorTexture(0, 0, 1, 1)
			elseif not isFollowing then
				box.texture:SetColorTexture(1, 1, 1, 1)
			elseif
				not AuraUtil.FindAuraByName(corruptionName, "target", "HARMFUL") and IsUsableSpell(corruptionName)
			then
				box.texture:SetColorTexture(1, 0, 0, 1)
			elseif not AuraUtil.FindAuraByName(immolateName, "target", "HARMFUL") and IsUsableSpell(immolateName) then
				box.texture:SetColorTexture(1, 0, 1, 1)
			elseif not AuraUtil.FindAuraByName(curseOfReck, "target", "HARMFUL") and IsUsableSpell(curseOfReck) then
				box.texture:SetColorTexture(0, 1, 1, 1)
			elseif not IsAutoRepeatSpell("Shoot") then
				box.texture:SetColorTexture(0, 1, 0, 1)
			else
				box.texture:SetColorTexture(0, 0, 0, 1)
			end
		else
			local health = UnitHealth("player")
			local maxHealth = UnitHealthMax("player")

			local hpPercent = (health / maxHealth) * 100
			local mana = UnitPower("player", 0) -- 0 is the ID for MANA
			local maxMana = UnitPowerMax("player", 0)
			local mppercent = (mana / maxMana) * 100

			if hpPercent > 50 and mppercent < 100 then
				box.texture:SetColorTexture(1, 0.5, 0.5, 1)
			else
				box.texture:SetColorTexture(0, 0, 0, 1)
			end
		end
	end
end)

box:RegisterEvent("AUTOFOLLOW_BEGIN")
box:RegisterEvent("AUTOFOLLOW_END")

box:SetScript("OnEvent", function(self, event, ...)
	if event == "AUTOFOLLOW_BEGIN" then
		local name = ...
		isFollowing = name
		print("Now following: " .. (name or "unknown"))
	elseif event == "AUTOFOLLOW_END" then
		isFollowing = nil
		print("Stopped following")
	end
end)

-- if AuraUtil.FindAuraByName(corruptionName, "target", "HARMFUL") then
-- 	print("Target has Corruption!")
-- end

-- local immolateName = GetSpellInfo(348)

-- if AuraUtil.FindAuraByName(immolateName, "target", "HARMFUL") then
-- 	print("Target has Immolate!")
-- end
-- local curseOfReck = GetSpellInfo(704)

-- if AuraUtil.FindAuraByName(curseOfReck, "target", "HARMFUL") then
-- 	print("Target has Curse of Recklessness!")
-- end
