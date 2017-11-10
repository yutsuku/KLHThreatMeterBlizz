local _G = getfenv()

local threatFrame = _G['TargetFrameNumericalThreat']

local function save_position()
	local point, relativeTo, relativePoint, x, y = threatFrame:GetPoint()
	
	KLHTMBlizzardUI_Parent = threatFrame:GetParent():GetName()
	KLHTMBlizzardUI_x = x
	KLHTMBlizzardUI_y = y
end

local function load_position()
	if KLHTMBlizzardUI_Parent and KLHTMBlizzardUI_x and KLHTMBlizzardUI_y then
		threatFrame:SetParent(KLHTMBlizzardUI_Parent)
		threatFrame:ClearAllPoints()
		threatFrame:SetPoint('BOTTOM', KLHTMBlizzardUI_Parent, 'TOP', KLHTMBlizzardUI_x, KLHTMBlizzardUI_y)
	end
end

local frame = CreateFrame('Frame')
frame:Hide()
frame.enableSnapping = false
frame.lastFrameID = 0
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function()
	if arg1 == 'KLHThreatMeterBlizz' then
		DEFAULT_CHAT_FRAME:AddMessage('snap loaded')
		load_position()
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
	threatFrame:SetPoint('BOTTOM', frame.snapFrameID, 'TOP', 0, -22)
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
		this.visual:SetFrameLevel(this.frameID:GetFrameLevel()+1)
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