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
		if UnitAffectingCombat("party1") then
			box.texture:SetColorTexture(1, 1, 0, 1)
			local targethealth = UnitHealth("target")
			local targetmaxHealth = UnitHealthMax("target")
			local hpPercent = (targethealth / targetmaxHealth) * 100

			local canattack = hpPercent < 95

			local corruptionName = GetSpellInfo(172)
			local immolateName = GetSpellInfo(348)
			local curseOfReck = GetSpellInfo(704)
			local sametarget = UnitIsUnit("target", "party1target")
			local spell = UnitCastingInfo("player")
			print("Casting: " .. (spell or "None"))

			if not sametarget then
				box.texture:SetColorTexture(0, 0, 1, 1)
			elseif not isFollowing then
				box.texture:SetColorTexture(1, 1, 1, 1)
			elseif
				not AuraUtil.FindAuraByName(corruptionName, "target", "HARMFUL")
				and IsUsableSpell(corruptionName)
				and canattack
			then
				box.texture:SetColorTexture(1, 0, 0, 1)
			elseif
				not AuraUtil.FindAuraByName(immolateName, "target", "HARMFUL")
				and IsUsableSpell(immolateName)
				and (spell ~= immolateName)
				and canattack
			then
				box.texture:SetColorTexture(1, 0, 1, 1)
			elseif
				not AuraUtil.FindAuraByName(curseOfReck, "target", "HARMFUL")
				and IsUsableSpell(curseOfReck)
				and canattack
			then
				box.texture:SetColorTexture(0, 1, 1, 1)
			elseif not IsAutoRepeatSpell("Shoot") and canattack then
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
