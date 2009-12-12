local interruptSpells = {
	[1766] = "Kick",
	[47528] = "Mind Freeze",
	[6552] = "Pummel",
	[72] = "Shield Bash",
	[2139] = "Counterspell"
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
			SendChatMessage(message, destination[1], nil, destination[2])
		end
	end
end

local onEvent = function(self, event, _, eventType, _, sourceName, sourceFlags, _, destName, destFlags, ...)
	if bit.band(sourceFlags, COMBATLOG_FILTER_ME) == COMBATLOG_FILTER_ME then
		if eventType == "SPELL_INTERRUPT" then
			local _, spellName, _, _, destSpellName = ...
	    local destIcon = CombatLog_String_GetIcon(destFlags)
			announce(format("%sed %s%s's %s", spellName, destIcon, destName, destSpellName))
	
	    --print("Interrupted", spellName, icon, destName)
		elseif eventType == "SPELL_CAST_SUCCESS" then
			print("Cast success", ...)
			local spellId, spellName = ...
			--	unit = getUnit(destGUID)

			if interruptSpells[spellId] then
				--	if unit and not UnitCastingInfo(unit) then
				print("Used", spellName, destName)
				--	end
			end
		elseif eventType == "SPELL_MISSED" and interruptSpells[spellId] then
			local _, spellName, _, missType = ...
	    local destIcon = CombatLog_String_GetIcon(destFlags)
			announce(format("Missed %s on %s%s (%s)", spellName, destIcon, destName, missType))
			
			print("Missed", spellName, icon, destName)
		end
	end
end

evl_Interrupt:SetScript("OnEvent", onEvent)
evl_Interrupt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local interruptFilter = function(self, event, text, author, ...)
	local ignore = true
	
	if find(text, "   $") then
		if GetNumRaidMembers() > 0 then
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

		return ignore, text, author
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", interruptMessageFilter)