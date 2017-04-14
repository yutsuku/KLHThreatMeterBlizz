--! This module references these other modules:
--! combat:	oneventinternal
--! table:	raiddata

--! This module is referenced by these other modules:

local mod = klhtm
local me = {}
mod.blizzardui = me

me.gui = {
	["Frame"] = TargetFrameNumericalThreat,
	["bg"] = TargetFrameNumericalThreatBG,
	["text"] = TargetFrameNumericalThreatValue,
}

me.myevents = { "PLAYER_TARGET_CHANGED", "CHAT_MSG_COMBAT_FRIENDLY_DEATH", "CHAT_MSG_SPELL_SELF_DAMAGE", "CHAT_MSG_COMBAT_SELF_HITS", "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "CHAT_MSG_SPELL_SELF_BUFF"}

-- register events
mod.events.blizzardui = {}
for _, event in me.myevents do
	mod.frame:RegisterEvent(event)
	mod.events.blizzardui[event] = true 
end

me.onevent = function()
	if event == "CHAT_MSG_COMBAT_FRIENDLY_DEATH" then
		if arg1 == UNITDIESSELF then -- You died.
			me.redraw()
		end
	elseif event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
		if string.find(arg1, PERIODICAURADAMAGESELFOTHER) then -- "%s suffers %d %s damage from your %s."
			me.redraw()
		end
	elseif event == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS" or event == "CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS" or event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
		if string.find(arg1, PERIODICAURAHEALSELFOTHER) then -- "%s gains %d health from your %s."
			me.redraw()
		end
	else
		me.redraw()
	end
end

me.redraw = function()
	if not UnitAffectingCombat("player") or UnitIsPlayer("target") then
		me.gui.Frame:Hide();
		return
	end
	
	local userThreat = mod.table.raiddata[UnitName("player")];
	local data, playerCount, threat100 = KLHTM_GetRaidData();
	local threat = 0
	if userThreat == nil then
		userThreat = 0
	end
	if threat100 == 0 then
		threat = 0
	else
		threat = math.floor(userThreat * 100 / threat100 + 0.5)
	end

	if ( threat and threat ~= 0 ) then
		me.gui.text:SetText(format("%d", threat).."%");
		me.gui.bg:SetVertexColor(me.GetThreatStatusColor(threat));
		me.gui.Frame:Show();
	else
		me.gui.Frame:Hide();
	end
end

me.GetThreatStatusColor = function(percentage)
	if not percentage then
		return 0.69, 0.69, 0.69
	end
	if percentage >= 90 then
		return 1.0, 0.0, 0.0
	elseif percentage >= 75 then
		return 1.0, 0.6, 0.0
	elseif percentage >= 55 then
		return 1.0, 1.0, 0.47
	else
		return 0.69, 0.69, 0.69
	end
end