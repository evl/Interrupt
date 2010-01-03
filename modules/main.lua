local interruptSpells = {
	[1766] = "Kick",
	[47528] = "Mind Freeze",
	[6552] = "Pummel",
	[72] = "Shield Bash",
	[2139] = "Counterspell",
	[57994] = "Wind Shear"
}

local announce = function(message)
	local destination
	
	if GetNumRaidMembers() > 0 then
		destination = evl_Interrupt.config.raid
	elseif GetNumPartyMembers() > 0 then
		destination = evl_Interrupt.config.party
	else
		destination = evl_Interrupt.config.solo
	end
	
	if destination then
		message = message .. "   " -- We use this to filter

		if #destination == 1 then
			SendChatMessage(message, destination[1])
		elseif #destination == 2 then
			SendChatMessage(message, destination[1], nil, GetChannelName(destination[2]))
		end
	end
end

local bit_band = _G.bit.band

local resolveUnit = function(guid)
	return (UnitGUID("target") and "target") or (guid == UnitGUID("focus") and "focus") or (guid == UnitGUID("mouseover") and "mouseover")
end

local icons = {"{star}", "{circle}", "{diamond}", "{triangle}", "{moon}", "{square}", "{cross}", "{skull}"}

local getUnitIcon = function(unit)
	local index = unit and GetRaidTargetIndex(unit) or nil
	return index and icons[index] or ""
end

local onEvent = function(self, event, _, eventType, _, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if bit_band(sourceFlags, COMBATLOG_FILTER_ME) == COMBATLOG_FILTER_ME then
		if eventType == "SPELL_INTERRUPT" then
			local _, spellName, _, _, destSpellName = ...
			local destUnit = resolveUnit(destGUID)
	    local destIcon = getUnitIcon(destUnit)

			announce(format("%sed %s%s's %s", spellName, destIcon, destName, destSpellName))
		elseif eventType == "SPELL_CAST_SUCCESS" then
			local spellId, spellName = ...

			if interruptSpells[spellId] then
				local destUnit = resolveUnit(destGUID)
		    local destIcon = getUnitIcon(destUnit)

				if not UnitCastingInfo(destUnit) then
					announce(format("Used %s on %s%s", spellName, destIcon, destName))
				end
			end
		elseif eventType == "SPELL_MISSED" and interruptSpells[spellId] then
			local _, spellName, _, missType = ...
			local destUnit = resolveUnit(destGUID)
	    local destIcon = getUnitIcon(destUnit)

			announce(format("Missed %s on %s%s (%s)", spellName, destIcon, destName, missType))
		end
	end
end

evl_Interrupt:SetScript("OnEvent", onEvent)
evl_Interrupt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local find = _G.string.find

local interruptMessageFilter = function(self, event, text, author, ...)
	local ignore = false
	
	if find(text, "   $") then
		ignore = true

		if UnitName("player") == author then
			ignore = false
		elseif GetNumRaidMembers() > 0 then
			for i = 1, MAX_RAID_MEMBERS do
				if UnitName("raid" .. i) == author then
					ignore = false
					break
				end
			end
		elseif GetNumPartyMembers() > 0 then
			for i = 1, MAX_PARTY_MEMBERS do
				if UnitName("party" .. i) == author then
					ignore = false
					break
				end
			end
		end
	end
	
	return ignore, text, author, ...
end

if evl_Interrupt.config.ignoreUnaffiliated then
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", interruptMessageFilter)
end