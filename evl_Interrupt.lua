evl_Interrupt = CreateFrame("Frame")
evl_Interrupt.config = {
	party = {"PARTY"},
	raid = {"CHANNEL", "namrogue"}
}

local interruptSpells = {
	[1766] = "Kick",
	[47528] = "Mind Freeze",
	[6552] = "Pummel",
	[72] = "Shield Bash",
	[2139] = "Counterspell"
}

local onEvent = function(event, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, _, missType)
	if bit.band(sourceFlags, COMBATLOG_FILTER_ME) == COMBATLOG_FILTER_ME then
		if eventType == "SPELL_INTERRUPT" then
	    local icon = CombatLog_String_GetIcon(destFlags)
	    print("Interrupted", spellName, icon, destName)
		--elseif eventType == "SPELL_CAST_SUCCESS" and interruptSpells[spellId] then
		--	unit = getUnit(destGUID)
	    	
		--	if unit and not UnitCastingInfo(unit) then
		--		print("Used", spellName, destName)
		--	end
		elseif eventType == "SPELL_MISSED" and interruptSpells[spellId] then
	    local icon = CombatLog_String_GetIcon(destFlags)
	    print("Missed", spellName, icon, destName)
		end
	end
end

evl_Interrupt:SetScript("OnEvent", onEvent)

-- Chat filter
local interruptFilter = function(self, event, text, author, ...)
	if find(text, incomingLinkPattern) then
		text = gsub(text, "{CLINK:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")
		text = gsub(text, "{CLINK:achievement:(%x+):(%-?%d-:%-?%x-:%-?%d-:%-?%d-:%-?%d-:%-?%d-:%-?%d-:%-?%d-:%-?%d-:%-?%d-):([^}]-)}", "|c%1|Hachievement:%2|h[%3]|h|r")
		text = gsub(text, "{CLINK:enchant:(%x+):([%d-]-):([^}]-)}", "|c%1|Henchant:%2|h[%3]|h|r")
		text = gsub(text, "{CLINK:glyph:(%x+):([%d-]-:[%d-]-):([^}]-)}", "|c%1|Hglyph:%2|h[%3]|h|r")
		text = gsub(text, "{CLINK:item:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")
		text = gsub(text, "{CLINK:quest:(%x+):([%d-]-):([%d-]-):([^}]-)}", "|c%1|Hquest:%2:%3|h[%4]|h|r")
		text = gsub(text, "{CLINK:spell:(%x+):([%d-]-):([^}]-)}", "|c%1|Hspell:%2|h[%3]|h|r")
		text = gsub(text, "{CLINK:talent:(%x+):([%d-]-:[%d-]-):([^}]-)}", "|c%1|Htalent:%2|h[%3]|h|r")
		text = gsub(text, "{CLINK:trade:(%x+):(%-?%d-:%-?%d-:.*:.*):([^}]-)}", "|c%1|Htrade:%2|h[%3]|h|r")
		
		return false, text, author, ...
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", incomingLinkFilter)