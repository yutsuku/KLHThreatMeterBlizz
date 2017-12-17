local _G = getfenv()

local threatFrame = _G['TargetFrameNumericalThreat']
local frame = CreateFrame('Frame')
frame:Hide()
frame.enableSnapping = false
frame.lastFrameID = 0

frame.lazyload = CreateFrame('Frame')
frame.lazyload.elapsed = 0
frame.lazyload.attempts = 0

_DEBUG_KTMBLIZZ = {}

local function save_position()
	local point, relativeTo, relativePoint, x, y = threatFrame:GetPoint()
	
	KLHTMBlizzardUI_Parent = threatFrame:GetParent():GetName()
	if point == 'TOPLEFT' and relativePoint == 'TOPLEFT' then
		relativeTo = threatFrame:GetParent()
		KLHTMBlizzardUI_x = x - relativeTo:GetLeft()
		KLHTMBlizzardUI_y = y + threatFrame:GetHeight()
		relativeTo = relativeTo:GetName()
	else
		KLHTMBlizzardUI_x = x
		KLHTMBlizzardUI_y = y
	end
	KLHTMBlizzardUI_point = point
	KLHTMBlizzardUI_relativePoint = relativePoint
	
	_DEBUG_KTMBLIZZ.save_position = {}
	_DEBUG_KTMBLIZZ.save_position.x = KLHTMBlizzardUI_x
	_DEBUG_KTMBLIZZ.save_position.y = KLHTMBlizzardUI_y
	_DEBUG_KTMBLIZZ.save_position.point = KLHTMBlizzardUI_point
	_DEBUG_KTMBLIZZ.save_position.relativePoint = KLHTMBlizzardUI_relativePoint
end

local function load_position()
	if KLHTMBlizzardUI_Parent and KLHTMBlizzardUI_x and KLHTMBlizzardUI_y and KLHTMBlizzardUI_point and KLHTMBlizzardUI_relativePoint then
		if not _G[KLHTMBlizzardUI_Parent] then
			if frame.lazyload.attempts >= 10 then
				frame.lazyload.enable = false
			else
				frame.lazyload.enable = true
			end
		else
			frame.lazyload.enable = false
			frame.lazyload:Hide()
			threatFrame:SetParent(KLHTMBlizzardUI_Parent)
			threatFrame:ClearAllPoints()
			threatFrame:SetPoint(KLHTMBlizzardUI_point, KLHTMBlizzardUI_Parent, KLHTMBlizzardUI_relativePoint, KLHTMBlizzardUI_x, KLHTMBlizzardUI_y)
			
			_DEBUG_KTMBLIZZ.load_position = {}
			_DEBUG_KTMBLIZZ.load_position.point = KLHTMBlizzardUI_point
			_DEBUG_KTMBLIZZ.load_position.relativePoint = KLHTMBlizzardUI_relativePoint
			_DEBUG_KTMBLIZZ.load_position.parent = KLHTMBlizzardUI_Parent
			_DEBUG_KTMBLIZZ.load_position.x = KLHTMBlizzardUI_x
			_DEBUG_KTMBLIZZ.load_position.y = KLHTMBlizzardUI_y
			_DEBUG_KTMBLIZZ.load_position.attempts = frame.lazyload.attempts
		end
	end
end

frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function()
	if arg1 == 'KLHThreatMeterBlizz' then
		_DEBUG_KTMBLIZZ.addon_loaded = true
		load_position()
	end
end)

frame.lazyload:SetScript('OnUpdate', function()
	if this.enable then
		this.elapsed = this.elapsed + arg1
		if this.elapsed >= 1 then
			this.elapsed = 0
			this.attempts = this.attempts + 1
			load_position()
		end
	end
end)

local visualFrame = CreateFrame('Frame', nil, UIParent)
frame.visual = visualFrame
visualFrame:SetBackdrop({
	bgFile=[[Interface\ChatFrame\ChatFrameBackground]],
	tile = true,
	tileSize = 16,
	edgeFile = [[Interface\Addons\KLHThreatMeterBlizz\textures\snap-border]],
	edgeSize = 16,
})
visualFrame:SetBackdropColor(0, 0, 0, .6)
visualFrame:SetScript('OnMouseDown', function()
	DEFAULT_CHAT_FRAME:AddMessage('Locking on')
	frame.enableSnapping = false
	klhtm.blizzardui.enableAdjust = true
	this:EnableMouse(false)
	
	local point, relativeTo, relativePoint, x, y = frame.snapFrameID:GetPoint()
	threatFrame:SetParent(frame.snapFrameID)
	threatFrame:ClearAllPoints()
	threatFrame:SetPoint('BOTTOM', frame.snapFrameID:GetName(), 'TOP', 0, 0)
	
	-- dear developers
	-- please stop making other developers life harder
	-- and just stick to blizzard' standards
	-- thank you
	if frame.snapFrameID:GetName() and strsub(frame.snapFrameID:GetName(), 1, 3) == 'LUF' then
		threatFrame:SetFrameLevel(frame.snapFrameID:GetFrameLevel()+10)
	end
	
	threatFrame:Show()
	
	threatFrame:SetMovable(true)
	threatFrame:EnableMouse(true)
	threatFrame:SetScript('OnMouseDown', function()
		if arg1 == 'LeftButton' then
			this:StartMoving()
		elseif arg1 == 'RightButton' then
			threatFrame:SetMovable(false)
			threatFrame:EnableMouse(false)
			threatFrame:Hide()
			visualFrame:Hide()
			klhtm.blizzardui.enableAdjust = false
			save_position()
			DEFAULT_CHAT_FRAME:AddMessage('Locked!')
		end
	end)
	threatFrame:SetScript('OnMouseUp', function()
		this:StopMovingOrSizing()
	end)
	
end)

frame:SetScript('OnUpdate', function()
	if not this.enableSnapping then
		return
	end
	
	this.frameID = GetMouseFocus()
	-- get 'real' focus 
	if this.enableSnapping and this.frameID and this.frameID == frame.visual then
		frame.visual:EnableMouse(false)
		this.frameID = GetMouseFocus()
		frame.visual:EnableMouse(true)
	end
	
	-- dumb check
	if not this.frameID or this.frameID == WorldFrame or this.frameID == UIParent or this.FrameID == this.visual then
		return
	end
	
	if this.frameID ~= this.lastFrameID then
		this.lastFrameID = this.frameID
		DEFAULT_CHAT_FRAME:AddMessage('Snapping to: '..tostring(this.frameID:GetName() or this.frameID))
		this.snapFrameID = this.frameID
		local point, relativeTo, relativePoint, x, y = this.frameID:GetPoint()
		x = x * ( (this.frameID:GetEffectiveScale() or 1) / (UIParent:GetScale() or 1) )
		y = y * ( (this.frameID:GetEffectiveScale() or 1) / (UIParent:GetScale() or 1) )
		this.visual:ClearAllPoints()
		this.visual:SetPoint(point, relativeTo, relativePoint, x, y)
		this.visual:SetWidth(this.frameID:GetWidth() * this.frameID:GetEffectiveScale() / UIParent:GetScale())
		this.visual:SetHeight(this.frameID:GetHeight() * this.frameID:GetEffectiveScale() / UIParent:GetScale())
		this.visual:SetFrameStrata(this.frameID:GetFrameStrata())
		
		if this.frameID:GetName() and strsub(this.frameID:GetName(), 1, 3) == 'LUF' then
			this.visual:SetFrameLevel(this.frameID:GetFrameLevel()+10)
		else
			this.visual:SetFrameLevel(this.frameID:GetFrameLevel()+1)
		end
		
	end
end)

SLASH_KTMBLIZZ1 = '/ktmsnap'
SLASH_KTMBLIZZ2 = '/threatsnap'
SlashCmdList["KTMBLIZZ"] = function(msg)
	frame.enableSnapping = not frame.enableSnapping
	
	if msg == 'reset' then
		KLHTMBlizzardUI_Parent = nil
		KLHTMBlizzardUI_x = nil
		KLHTMBlizzardUI_y = nil
		KLHTMBlizzardUI_point = nil
		KLHTMBlizzardUI_relativePoint = nil
		ReloadUI()
		return
	end
	
	if frame.enableSnapping then
		klhtm.blizzardui.enableAdjust = false
		frame:Show()
		frame.visual:EnableMouse(true)
		frame.visual:Show()
	else
		frame:Hide()
		frame.visual:EnableMouse(false)
		frame.visual:Hide()
	end
end