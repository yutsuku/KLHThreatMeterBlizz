--! This module references these other modules:
--! table:	raiddata

--! This module is referenced by these other modules:

local mod = klhtm
local me = {}
local update_freq = 0.5
local last_update = 0
local GetTime = GetTime
local UnitName = UnitName

mod.blizzardui = me
me.isenabled = true 

me.gui = {
	["Frame"] = TargetFrameNumericalThreat,
	["bg"] = TargetFrameNumericalThreatBG,
	["text"] = TargetFrameNumericalThreatValue,
}

me.gui.Frame:SetScript('OnEvent', function()
	this[event](this)
end)
me.gui.Frame:RegisterEvent('PLAYER_REGEN_DISABLED')
me.gui.Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
me.gui.Frame:RegisterEvent('RAID_ROSTER_UPDATE')
me.gui.Frame:RegisterEvent('PARTY_MEMBERS_CHANGED')

me.gui.Frame.PLAYER_REGEN_DISABLED = function()
	me.isenabled = true
end

me.gui.Frame.PLAYER_REGEN_ENABLED = function()
	me.isenabled = 'false'
	me.gui.Frame:Hide()
end

me.gui.Frame.RAID_ROSTER_UPDATE = function()
	me.playerschanged()
end

me.gui.Frame.PARTY_MEMBERS_CHANGED = function()
	me.playerschanged()
end

me.playerschanged = function()
	local playersRaid = GetNumRaidMembers()
	local playersParty = GetNumPartyMembers()
	local inGroup = false
	
	if playersRaid > 0 then
		inGroup = true
	elseif playersParty > 0 then
		inGroup = true
	end
	
	if not inGroup then
		me.group = false
		me.isenabled = 'false'
		me.gui.Frame:Hide()
	else
		me.group = true
		me.isenabled = true
	end
end

me.onupdate = function()
	if last_update > GetTime()+update_freq then
		return
	end
	me.redraw()
end

me.redraw = function()
	if klhtm.blizzardui.enableAdjust then
		return
	end
	
	if not UnitAffectingCombat('player') or UnitIsPlayer('target') or not me.group then
		me.gui.Frame:Hide()
		return
	end
	
	local userThreat = mod.table.raiddata[UnitName('player')]
	local data, playerCount, threat100 = KLHTM_GetRaidData()
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
		me.gui.text:SetText(format("%d", threat).."%")
		me.gui.bg:SetVertexColor(me.GetThreatStatusColor(threat))
		me.gui.Frame:Show()
	else
		me.gui.Frame:Hide()
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