local addonInfo, privateVars = ...

---------- init namespace ---------

local data			= privateVars.data
local uiElements	= privateVars.uiElements
local _internal		= privateVars.internal
local _events		= privateVars.events
local _ui			= privateVars.ui
local oFuncs		= privateVars.oFuncs

---------- init local variables ---------

local _eventHandlers = {}

---------- init variables ---------

---------- local function block ---------

---------- addon internal function block ---------

privateVars.effects = {
	gloss = { alpha = 0.6, texturePath = 'gfx/iconDesignGloss.png', replaceBorder = false },
	round = { alpha = 0.6, texturePath = 'gfx/iconDesignRound.png', replaceBorder = false },
	basic = { alpha = 0.5, texturePath = 'gfx/iconDesignBasic.png', replaceBorder = false },
	chrome = { alpha = 1, texturePath = 'gfx/iconDesignChrome.png', replaceBorder = true, border = 7},
	roundedCorners = { alpha = 1, texturePath = 'gfx/iconDesignRoundedCorners.png', replaceBorder = true, border = 1},
}

function _ui.icon (name, parent)
	
	local icon = EnKai.uiCreateFrame('nkFrame', name, parent)
	
	local border = EnKai.uiCreateFrame('nkFrame', name .. '.border', icon)
	local texture = EnKai.uiCreateFrame('nkTexture', name .. '.texture', icon)
	local effect = EnKai.uiCreateFrame('nkTexture', name .. '.effect', icon)
	
	local timer = EnKai.uiCreateFrame('nkText', name ..'.timer', icon)
	local stack = EnKai.uiCreateFrame('nkText', name ..'.stack', icon)
	
	local label = EnKai.uiCreateFrame('nkText', name .. 'label', icon)
	
	local properties = {}

	function icon:SetValue(property, value)
		properties[property] = value
	end
	
	function icon:GetValue(property)
		return properties[property]
	end
	
	icon:SetValue("name", name)
	icon:SetValue("parent", parent)
	
	icon:SetMouseMasking('limited')
	
	icon:EventAttach(Event.UI.Input.Mouse.Left.Down, function (self)
		
		if not data.configOpen then return end
		
		uiElements.configUI:EditIcon(icon)
	
	end, name .. "button.Left.Down")
	
	local dragable = false
	local showTooltip = false
	local timerFontSize = 24
	local stackFontSize = 18
	local labelFontSize = 16
	local showBorder = true
	local activeEffect = 'none'
	local scale = 1
		
	icon:SetWidth(50)
	icon:SetHeight(65)
	icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, 100)
	
	border:SetPoint("TOPLEFT", icon, "TOPLEFT")
	border:SetWidth(50)
	border:SetHeight(50)
	border:SetBackgroundColor(0, 0, 0, 1)
	border:SetLayer(1)
	
	texture:SetPoint("TOPLEFT", border, "TOPLEFT", 1, 1)
	texture:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, -1)
	texture:SetLayer(2)
	
	timer:SetLayer(4)
	timer:SetFontColor(1, 1, 1, 0)
	timer:SetFontSize(timerFontSize)
	timer:SetHeight(timerFontSize+4)
	timer:SetPoint("CENTER", border, "CENTER")
	
	stack:SetLayer(4)
	stack:SetFontColor(1, 1, 1, 0)
	stack:SetFontSize(stackFontSize)
	stack:SetPoint("TOPLEFT", icon, "TOPLEFT", 0 , -1)
		
	label:SetPoint("TOPCENTER", border, "BOTTOMCENTER")
	label:SetFontColor (1, 1, 1, 1)
	label:SetFontSize(labelFontSize)
	label:SetHeight(labelFontSize+4)
	
	effect:SetLayer(3)
	effect:SetVisible(false)
	
	function icon:SetTexture(textureType, texturePath)
		texture:SetTextureAsync(textureType, texturePath)
	end
	
	function icon:SetLabel(text)
		label:ClearWidth()
		label:SetText(text)
	end
	
	function icon:SetTimer(text)
		timer:ClearWidth()
		timer:SetText(text)
	end
	
	function icon:SetStack(text)
		stack:ClearWidth()
		if text == nil then
			stack:SetText("")
		else
			stack:SetText(tostring(text))
		end
	end
	
	function icon:ShowLabel(flag)
		label:SetVisible(flag)
	end
	
	function icon:ShowTimer(flag)
		timer:SetVisible(flag)
	end
	
	function icon:ShowStack(flag)
		stack:SetVisible(flag)
	end
	
	function icon:ShowBorder(flag)
	
		showBorder = flag
		
		effect:ClearAll()
		texture:ClearAll()
	
		if flag == true then
			texture:SetPoint("TOPLEFT", border, "TOPLEFT", 1, 1)
			texture:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, -1)
			
			effect:SetPoint("TOPLEFT", border, "TOPLEFT", 1, 1)
			effect:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, -1)
		else
			texture:SetPoint("TOPLEFT", border, "TOPLEFT", 0, 0)
			texture:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 0, 0)
			
			effect:SetPoint("TOPLEFT", border, "TOPLEFT", 0, 0)
			effect:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 0, 0)
		end
	end
	
	function icon:SetScale(newScale)
		scale = newScale
	
		icon:SetWidth( 50 * newScale)
		icon:SetHeight( 50 * newScale)
		
		border:SetWidth( 50 * newScale)
		border:SetHeight( 50 * newScale)
		
		local fontSize = math.floor(labelFontSize * newScale)
		
		label:SetFontSize(fontSize)
		label:SetHeight(fontSize + 4)
		
		local fontSize = math.floor(timerFontSize * newScale)
		
		timer:SetFontSize(fontSize)
		timer:SetHeight(fontSize + 4)
		
		local fontSize = math.floor(stackFontSize * newScale)
		
		stack:SetFontSize(fontSize )
	end
	
	function icon:SetLabelColor(r, g, b, a)
		label:SetFontColor(r, g, b, a)
	end
	
	function icon:SetTimerColor(r, g, b, a, ro, go, bo)
		timer:SetFontColor(r, g, b, a)
		timer:SetEffectGlow({ strength = 5, offsetX = 0, offsetY = 0, blurX = 3, blurY = 3, colorR = ro, colorG = go, colorB = bo })
	end
	
	function icon:SetStackColor(r, g, b, a)
		stack:SetFontColor(r, g, b, a)
		stack:SetEffectGlow({ offsetX = 1, offsetY = 1})
	end
	
	function icon:SetBorderColor(r, g, b, a)
		border:SetBackgroundColor(r, g, b, a)
	end
	
	function icon:SetInfoBlock (header, desc)
		icon:SetValue('infoBlockHeader', header)
		icon:SetValue('infoBlockDesc', desc)
		EnKai.ui.attachGenericTooltip(icon, header, desc or "")
	end
	
	function icon:SetDragable(flag)
	
		if flag == false then 
		
 			if dragable == true then
				icon:EventDetach(Event.UI.Input.Mouse.Left.Down, nil, name .. ".Left.Down")
				icon:EventDetach(Event.UI.Input.Mouse.Cursor.Move, nil, name .. ".Cursor.Move")
				icon:EventDetach(Event.UI.Input.Mouse.Left.Up, nil, name .. ".Left.Up")
			end
			
		else
		
			icon:EventAttach(Event.UI.Input.Mouse.Left.Down, function (self)		
			
				if dragable == false then return end
				
				self.leftDown = true
				local mouse = oFuncs.InspectMouse()
				
				self.originalXDiff = mouse.x - self:GetLeft()
				self.originalYDiff = mouse.y - self:GetTop()
				
				local left, top, right, bottom = icon:GetBounds()
				
				icon:ClearAll()
				icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
				icon:SetWidth(right-left)
				icon:SetHeight(bottom-top)
			
			end, name .. ".Left.Down")
				
			icon:EventAttach( Event.UI.Input.Mouse.Cursor.Move, function (self, _, x, y)	
				if self.leftDown ~= true then return end
				icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - self.originalXDiff, y - self.originalYDiff)
			end, name .. ".Cursor.Move")
			
			icon:EventAttach( Event.UI.Input.Mouse.Left.Up, function (self)	
				if self.leftDown ~= true then return end
			    self.leftDown = false
				
				local iconDef
				if icon:GetValue("setType") == 'mainSet' then
					iconDef = nkRBSetMain[icon:GetValue("activeSet")].icons[icon:GetValue('triggerId')]
				else
					iconDef = nkRBSetSub[icon:GetValue("activeSet")].icons[icon:GetValue('triggerId')]
				end
				
				
				iconDef.ypos = icon:GetTop()
				iconDef.xpos = icon:GetLeft()

				local xDiff, yDiff = 1000, 1000
				local snapIcon = nil
				
				local setList = _internal.getSetList()
				
				for setType, setDetails in pairs(setList) do
				
					for triggerId, iconDef in pairs(setDetails.icons) do
					
						local snapped = false
						
						if setType ~= icon:GetValue('setType') or triggerId ~= icon:GetValue('triggerId') then
						
							local thatIcon = uiElements.icons[iconDef.uiId]
								
							if thatIcon ~= nil then
							
								local diffX, diffY = 1000, 1000
										
								if icon:GetLeft() > (thatIcon:GetLeft() + thatIcon:GetWidth()) and icon:GetLeft() - (thatIcon:GetLeft() + thatIcon:GetWidth()) < 20 then
									diffX = icon:GetLeft() - (thatIcon:GetLeft() + thatIcon:GetWidth())
								end
								
								if icon:GetLeft() + icon:GetWidth() < thatIcon:GetLeft() and thatIcon:GetLeft() - (icon:GetLeft() + icon:GetWidth()) < 20 then
									diffX = thatIcon:GetLeft() - (icon:GetLeft() + icon:GetWidth())
								end
								
								if icon:GetTop() > (thatIcon:GetTop() + thatIcon:GetHeight()) and icon:GetTop() - (thatIcon:GetTop() + thatIcon:GetHeight()) < 20 then
									diffY = icon:GetTop() - (thatIcon:GetTop() + thatIcon:GetHeight())
								end
								
								if icon:GetTop() + icon:GetHeight() < thatIcon:GetTop() and thatIcon:GetTop() - (icon:GetTop() + icon:GetHeight()) < 20 then
									diffY = thatIcon:GetTop() - (icon:GetTop() + icon:GetHeight())
								end
								
								if diffX ~= 1000 or diffY ~= 1000 then
								
									if diffX ~= 1000 and math.abs(icon:GetTop() - thatIcon:GetTop()) < icon:GetHeight() then
										snapIcon = thatIcon
										xDiff = diffX
										yDiff = diffY
									elseif diffY ~= 1000 and math.abs(icon:GetLeft() - thatIcon:GetLeft()) < icon:GetWidth() then
										snapIcon = thatIcon
										xDiff = diffX
										yDiff = diffY
									end
								end
							end
						end
					end
				end
				
				if snapIcon ~= nil then
								
					local left, top, right, bottom = icon:GetBounds()
					local xpos, ypos = icon:GetLeft(), icon:GetTop()
					icon:ClearAll()
					
					if xDiff ~= 1000 then
						if snapIcon:GetLeft() < xpos then
							icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", snapIcon:GetLeft() + snapIcon:GetWidth()-1, snapIcon:GetTop())
						else
							icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", snapIcon:GetLeft() - (right-left-1), snapIcon:GetTop())
						end
					else
						if snapIcon:GetTop() < ypos then
							icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", snapIcon:GetLeft(), snapIcon:GetTop() + snapIcon:GetHeight() -1)
						else
							icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", snapIcon:GetLeft(), snapIcon:GetTop() - (bottom-top-1))
						end
					end
				
					icon:SetWidth(right-left)
					icon:SetHeight(bottom-top)
					
					-- local iconDef
					-- if icon:GetValue("setType") == 'mainSet' then
						-- iconDef = nkRBSetMain[icon:GetValue("activeSet")].icons[icon:GetValue('triggerId')]
					-- else
						-- iconDef = nkRBSetSub[icon:GetValue("activeSet")].icons[icon:GetValue('triggerId')]
					-- end
					
					iconDef.ypos = icon:GetTop()
					iconDef.xpos = icon:GetLeft()
				end
				
				_eventHandlers[name]["Moved"]()
			end, name .. ".Left.Up")
		end
		
		dragable = flag
		
	end
	
	function icon:SetEffect(newEffect)
		activeEffect = newEffect
	
		if newEffect == nil then
			effect:SetVisible(false)
			return
		end
	
		effect:SetTextureAsync("nkRebuff", newEffect.texturePath)
		effect:SetAlpha(newEffect.alpha)
		
		effect:ClearAll()
		texture:ClearAll()
		
		if newEffect.replaceBorder == false and showBorder == true then
			effect:SetPoint("TOPLEFT", border, "TOPLEFT", 1, 1)
			effect:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, -1)
			
			texture:SetPoint("TOPLEFT", border, "TOPLEFT", 1, 1)
			texture:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, -1)
			
			border:SetVisible(true)
		else
			effect:SetPoint("TOPLEFT", border, "TOPLEFT")
			effect:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT")
			
			if newEffect.border == nil then
				texture:SetPoint("TOPLEFT", border, "TOPLEFT", 1, 1)
				texture:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, -1)				
			else
				texture:SetPoint("CENTER", border, "CENTER")			
				local width, height = icon:GetWidth(), icon:GetHeight()
			
				if newEffect.border ~= nil then
					width = math.floor(width - (newEffect.border * 2 * (50 / width)))
					height = math.floor(height - (newEffect.border * 2 * (50 / height)))
					
				end
				
				texture:SetWidth(width)
				texture:SetHeight(height)
			end			
			
			border:SetVisible(false)
		end
		
		effect:SetVisible(true)
		
	end
	
	function icon:Recycle()
		icon:SetVisible(false)
		icon:EventDetach(Event.UI.Input.Mouse.Cursor.In, nil, name .. '.Mouse.Cursor.In')
		icon:EventDetach(Event.UI.Input.Mouse.Cursor.Out, nil, name .. '.Mouse.Cursor.Out')
		icon:EventDetach(Event.UI.Input.Mouse.Left.Down, nil, name .. ".Left.Down")
		icon:EventDetach(Event.UI.Input.Mouse.Cursor.Move, nil, name .. ".Cursor.Move")
		icon:EventDetach(Event.UI.Input.Mouse.Left.Up, nil, name .. ".Left.Up")
	end
	
	if _eventHandlers[name] == nil then -- if event exists the icon was used before	
		_eventHandlers[name] = {}
		privateVars.events[name] = {}
		_eventHandlers[name]["Moved"], privateVars.events[name]["Moved"] = Utility.Event.Create(addonInfo.identifier, name .. "Moved")
	end
	
	return icon
	
end