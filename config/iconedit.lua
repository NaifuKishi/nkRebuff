local addonInfo, privateVars = ...

---------- init namespace ---------

local data			= privateVars.data
local uiElements	= privateVars.uiElements
local _internal		= privateVars.internal
local _events		= privateVars.events
local _ui			= privateVars.ui

---------- init local variables ---------

---------- init variables ---------

---------- local function block ---------

---------- addon internal function block ---------

function _ui.iconEdit (parent)

	local name = parent:GetName() .. '.iconEdit'

	local iconData, key, set, setType, unitType, buffType, displayLabel 
	local iconEdit, content, triggerLabel, showIfRB, useDefaultsCB, showLabelCB, showBorderCB, showTimerCB, timerOutlineLabel, showStackCB, labelColor, borderColor, timerColor, timerOutlineColor, stackColor, sliderScale, sliderwarnDurationLessThan
	local editLabel, selectTexture, editXPos, editYPos, slash, moveUp, moveDown, moveLeft, moveRight, updateButton, deleteButton, overrideLabel, positionLabel, stackCountSlider, showStackRB, iconActiveCB
	
	local function _fctSetImage(textureType, texturePath)
		selectTexture:AddImages({{ textureType = textureType, texturePath = texturePath }}, false )
		local pos = selectTexture:FindImagePos (textureType, texturePath)
		selectTexture:SetImagePos(pos)
	end
	
	local function _fctReadConfig()
	
		iconData = EnKai.tools.table.copy(nkRBConfig.iconDefaults)
		
		iconData.useDefaults = useDefaultsCB:GetChecked()
	
		if useDefaultsCB:GetChecked() == false then
			iconData.showLabel = showLabelCB:GetChecked()
			iconData.showBorder = showBorderCB:GetChecked()
			iconData.showTimer = showTimerCB:GetChecked()
			iconData.labelColor = { labelColor:GetColor() }
			iconData.borderColor = {  borderColor:GetColor() }
			iconData.timerColor = {  timerColor:GetColor() }
			iconData.timerOutlineColor = { timerOutlineColor:GetColor() }
			iconData.stackColor =  {  stackColor:GetColor() }
			iconData.scale = sliderScale:GetValue('value')
			iconData.warnDurationLessThan = sliderwarnDurationLessThan:GetValue('value')
		end

		iconData.showStack = showStackCB:GetChecked()
		iconData.label = editLabel:GetText()
		iconData.textureType = selectTexture:GetImage(selectTexture:GetImagePos()).textureType
		iconData.texturePath = selectTexture:GetImage(selectTexture:GetImagePos()).texturePath
		iconData.xpos = tonumber(editXPos:GetText())
		iconData.ypos = tonumber(editYPos:GetText())
		
	end
	
	local function _fctUpdateIcon()
	
		local rbSet = _internal.getSetByType (setType, set)
		local icon = uiElements.icons[rbSet.icons[key].uiId]
	
		icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", iconData.xpos, iconData.ypos)
		icon:SetTexture(iconData.textureType, iconData.texturePath)
		icon:ShowLabel(iconData.showLabel)
		icon:ShowBorder(iconData.showBorder)
		icon:ShowTimer(iconData.showTimer)
		icon:ShowStack(iconData.showStack)
		
		icon:SetScale(iconData.scale / 100)
		
		icon:SetBorderColor (iconData.borderColor[1], iconData.borderColor[2], iconData.borderColor[3], iconData.borderColor[4])
		icon:SetLabelColor (iconData.labelColor[1], iconData.labelColor[2], iconData.labelColor[3], iconData.labelColor[4])
		icon:SetTimerColor (iconData.timerColor[1], iconData.timerColor[2], iconData.timerColor[3], iconData.timerColor[4],
		                    iconData.timerOutlineColor[1], iconData.timerOutlineColor[2], iconData.timerOutlineColor[3])
		icon:SetStackColor (iconData.stackColor[1], iconData.stackColor[2], iconData.stackColor[3], iconData.stackColor[4])
		
		icon:SetLabel(_internal.ComputeLabel(iconData.label))
		
		local uiId = rbSet.icons[key].uiId
		rbSet.icons[key] = EnKai.tools.table.copy(iconData)
		rbSet.icons[key].uiId = uiId
		
		rbSet.trigger[key].active = iconActiveCB:GetChecked()
		rbSet.trigger[key].showIfActive = showIfRB:GetSelectedValue()
		rbSet.trigger[key].stackTrigger = showStackRB:GetSelectedValue()
		rbSet.trigger[key].stackCounter = stackCountSlider:GetValue('value')
			
	end
	
	-- ui layout
	
	iconEdit = EnKai.uiCreateFrame('nkFrame', name, parent)
	
	content = EnKai.uiCreateFrame('nkFrame', name .. '.content', iconEdit)
	
	triggerLabel = EnKai.uiCreateFrame("nkText", name .. '.triggerLabel', content)
	triggerLabel:SetFontSize(14)
	triggerLabel:SetFontColor(1,1,1,1)
	triggerLabel:SetEffectGlow({ offsetX = 2, offsetY = 2})
	triggerLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 370, 0)
	triggerLabel:SetText(privateVars.langTexts.triggerLabel)
	
	iconActiveCB = EnKai.uiCreateFrame("nkCheckbox", name .. '.iconActiveCB', content)	
	iconActiveCB:SetPoint("TOPLEFT", triggerLabel, "BOTTOMLEFT", 0, 7)
	iconActiveCB:SetText(privateVars.langTexts.iconActive)
	iconActiveCB:SetWidth(168)
	
	showIfRB = EnKai.uiCreateFrame("nkRadioButton", name .. '.showIfRB', content)
	showIfRB:SetPoint("TOPLEFT", iconActiveCB, "BOTTOMLEFT", 0, 11)
	showIfRB:SetText(privateVars.langTexts.showIf)
	showIfRB:SetWidth(300)
	showIfRB:SetLabelWidth(150)
	showIfRB:SetSelection(privateVars.langTexts.showIfSelection)
	
	showStackRB = EnKai.uiCreateFrame("nkRadioButton", name .. '.showStackRB', content)	
	showStackRB:SetPoint("TOPLEFT", showIfRB, "BOTTOMLEFT", 0, 11)
	showStackRB:SetText(privateVars.langTexts.showIfStack)
	showStackRB:SetWidth(300)
	showStackRB:SetLabelWidth(150)
	showStackRB:SetSelection(privateVars.langTexts.showIfStackSelection)
	
	stackCountSlider = EnKai.uiCreateFrame("nkSlider", name .. '.stackCountSlider', content)
	stackCountSlider:SetPoint("TOPLEFT", showStackRB, "BOTTOMLEFT", 125, 10)
	stackCountSlider:SetRange(0, 10)
	stackCountSlider:AdjustValue(0)
	stackCountSlider:SetLabelWidth(25)
	stackCountSlider:SetWidth(165)
	stackCountSlider:SetText("%d")
	
	displayLabel = EnKai.uiCreateFrame("nkText", name .. '.displayLabel', content)
	displayLabel:SetFontSize(14)
	displayLabel:SetFontColor(1,1,1,1)
	displayLabel:SetEffectGlow({ offsetX = 2, offsetY = 2})
	displayLabel:SetPoint("TOPLEFT", showStackRB, "BOTTOMLEFT", 0, 46)
	displayLabel:SetText(privateVars.langTexts.displayLabel)
	
	showStackCB = EnKai.uiCreateFrame("nkCheckbox", name .. '.showStackCB', content)
	showStackCB:SetPoint("TOPLEFT", displayLabel, "BOTTOMLEFT", 0, 7)
	showStackCB:SetText(privateVars.langTexts.showStack)
	showStackCB:SetChecked(true)
	showStackCB:SetWidth(168)
	
	stackColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.stackColor', content)
	stackColor:SetPoint("CENTERLEFT", showStackCB, "CENTERRIGHT", 20, 0 )
	stackColor:SetWidth(80)
	stackColor:SetHeight(15)
	stackColor:SetText(privateVars.langTexts.color)
	stackColor:SetColor(nkRBConfig.iconDefaults.stackColor[1], nkRBConfig.iconDefaults.stackColor[2], nkRBConfig.iconDefaults.stackColor[3], 1)
	stackColor:SetLayer(2)
	
	useDefaultsCB = EnKai.uiCreateFrame("nkCheckbox", name .. '.useDefaultsCB', content)	
	useDefaultsCB:SetPoint("TOPLEFT", showStackCB, "BOTTOMLEFT", 0, 11)
	useDefaultsCB:SetText(privateVars.langTexts.useDefaults)
	useDefaultsCB:SetChecked(true)
	useDefaultsCB:SetWidth(168)
	
	Command.Event.Attach(EnKai.events[useDefaultsCB:GetName()].CheckboxChanged, function (_, newValue)
		local flag = not newValue
		showLabelCB:SetActive(flag)
		showBorderCB:SetActive(flag)
		showTimerCB:SetActive(flag)
		labelColor:SetActive(flag)
		borderColor:SetActive(flag)
		timerColor:SetActive(flag)
		timerOutlineColor:SetActive(flag)
		sliderScale:SetActive(flag)
		sliderwarnDurationLessThan:SetActive(flag)
	end, useDefaultsCB:GetName() .. '.CheckboxChanged')
	
	showLabelCB = EnKai.uiCreateFrame("nkCheckbox", name .. '.showLabelCB', content)	
	showLabelCB:SetPoint("TOPLEFT", useDefaultsCB, "BOTTOMLEFT", 0, 11)
	showLabelCB:SetText(privateVars.langTexts.showLabel)
	showLabelCB:SetChecked(true)
	showLabelCB:SetWidth(168)
	showLabelCB:SetActive(false)

	labelColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.labelColor', content)
	labelColor:SetPoint("CENTERLEFT", showLabelCB, "CENTERRIGHT", 20, 0 )
	labelColor:SetWidth(80)
	labelColor:SetHeight(15)
	labelColor:SetText(privateVars.langTexts.color)
	labelColor:SetColor(nkRBConfig.iconDefaults.labelColor[1], nkRBConfig.iconDefaults.labelColor[2], nkRBConfig.iconDefaults.labelColor[3], 1)
	labelColor:SetActive(false)
	labelColor:SetLayer(2)
	
	showBorderCB = EnKai.uiCreateFrame("nkCheckbox", name .. '.showBorderCB', content)	
	showBorderCB:SetPoint("TOPLEFT", showLabelCB, "BOTTOMLEFT", 0, 11)
	showBorderCB:SetText(privateVars.langTexts.showBorder)
	showBorderCB:SetChecked(true)
	showBorderCB:SetWidth(168)
	showBorderCB:SetActive(false)
	
	borderColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.borderColor', content)
	borderColor:SetPoint("CENTERLEFT", showBorderCB, "CENTERRIGHT", 20, 0)
	borderColor:SetWidth(80)
	borderColor:SetHeight(15)
	borderColor:SetText(privateVars.langTexts.color)
	borderColor:SetColor(nkRBConfig.iconDefaults.borderColor[1], nkRBConfig.iconDefaults.borderColor[2], nkRBConfig.iconDefaults.borderColor[3], 1)
	borderColor:SetLayer(2)
	borderColor:SetActive(false)
	
	showTimerCB = EnKai.uiCreateFrame("nkCheckbox", name .. '.showTimerCB', content)
	showTimerCB:SetPoint("TOPLEFT", showBorderCB, "BOTTOMLEFT", 0, 11)
	showTimerCB:SetText(privateVars.langTexts.showTimer)
	showTimerCB:SetChecked(true)
	showTimerCB:SetWidth(168)
	showTimerCB:SetActive(false)
	
	timerColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.timerColor', content)
	timerColor:SetPoint("CENTERLEFT", showTimerCB, "CENTERRIGHT", 20, 0 )
	timerColor:SetWidth(80)
	timerColor:SetHeight(15)
	timerColor:SetText(privateVars.langTexts.color)
	timerColor:SetColor(nkRBConfig.iconDefaults.timerColor[1], nkRBConfig.iconDefaults.timerColor[2], nkRBConfig.iconDefaults.timerColor[3], 1)
	timerColor:SetLayer(2)
	timerColor:SetActive(false)
	
	timerOutlineColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.timerOutlineColor', content)
	timerOutlineColor:SetPoint("CENTERLEFT", timerColor, "CENTERRIGHT", 10, 0 )
	timerOutlineColor:SetWidth(15)
	timerOutlineColor:SetHeight(15)
	timerOutlineColor:SetColor(nkRBConfig.iconDefaults.timerOutlineColor[1], nkRBConfig.iconDefaults.timerOutlineColor[2], nkRBConfig.iconDefaults.timerOutlineColor[3], 1)
	timerOutlineColor:SetLayer(2)
	timerOutlineColor:SetActive(false)
  
	sliderScale = EnKai.uiCreateFrame("nkSlider", name .. 'sliderScale', content)
	sliderScale:SetPoint("TOPLEFT", showTimerCB, "BOTTOMLEFT", 0, 10)
	sliderScale:SetRange(20, 150)
	sliderScale:AdjustValue(100)
	sliderScale:SetLabelWidth(150)
	sliderScale:SetWidth(236)
	sliderScale:SetText(privateVars.langTexts.scale)
	sliderScale:SetActive(false)
	
	sliderwarnDurationLessThan = EnKai.uiCreateFrame("nkSlider", name .. '.warnDurationLessThan', content)
	sliderwarnDurationLessThan:SetPoint("TOPLEFT", sliderScale, "BOTTOMLEFT", 0, 10)
	sliderwarnDurationLessThan:SetRange(0, 120)
	sliderwarnDurationLessThan:AdjustValue(20)
	sliderwarnDurationLessThan:SetLabelWidth(150)
	sliderwarnDurationLessThan:SetWidth(236)
	sliderwarnDurationLessThan:SetText(privateVars.langTexts.runOutWarning)
	sliderwarnDurationLessThan:SetActive(false)
	
	overrideLabel = EnKai.uiCreateFrame("nkText", name .. '.overrideLabel', content)
	overrideLabel:SetFontSize(14)
	overrideLabel:SetFontColor(1,1,1,1)
	overrideLabel:SetEffectGlow({ offsetX = 2, offsetY = 2})
	overrideLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 310)
	overrideLabel:SetText(privateVars.langTexts.overrideLabel)
	
	editLabel = EnKai.uiCreateFrame("nkTextfield", name .. '.editLabel', content)
	editLabel:SetPoint("TOPLEFT", overrideLabel, "BOTTOMLEFT", 0, 4)
	editLabel:SetWidth(322)
	editLabel:SetHeight(22)
	
	selectTexture = EnKai.uiCreateFrame("nkImageGallery", name .. '.selectTexture', content)
	selectTexture:SetPoint("TOPLEFT", editLabel, "BOTTOMLEFT", 0, 5)
	selectTexture:SetDefaultImages(true)
	
	positionLabel = EnKai.uiCreateFrame("nkText", name .. '.positionLabel', content)
	positionLabel:SetFontSize(14)
	positionLabel:SetFontColor(1,1,1,1)
	positionLabel:SetEffectGlow({ offsetX = 2, offsetY = 2})
	positionLabel:SetPoint("TOPLEFT", sliderwarnDurationLessThan, "BOTTOMLEFT", 0, 22)
	positionLabel:SetText(privateVars.langTexts.positionLabel)
	
	editXPos = EnKai.uiCreateFrame("nkTextfield", name .. '.editXPos', content)
	editYPos = EnKai.uiCreateFrame("nkTextfield", name .. '.editYPos', content)
	slash = EnKai.uiCreateFrame('nkText', name ..'.slash', content)
	
	moveUp = UI.CreateFrame('Texture', name ..'.moveUp', content)
	moveUp:SetPoint ("CENTERBOTTOM", slash, "CENTERTOP", 0, -10)
	moveUp:SetTextureAsync('EnKai', 'gfx/icons/small-arrowUp.png')
	
	moveUp:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
		iconData.ypos = iconData.ypos - 1
		if iconData.ypos < 1 then iconData.ypos = 1 end
		_fctUpdateIcon()
		editYPos:SetText(tostring(iconData.ypos))
	end, moveUp:GetName() .. '.UI.Input.Mouse.Left.Click')
	
	moveDown = EnKai.uiCreateFrame('nkTexture', name ..'.moveDown', content)
	moveDown:SetPoint ("CENTERTOP", slash, "CENTERBOTTOM", 0, 10)
	moveDown:SetTextureAsync('EnKai', 'gfx/icons/small-arrowDown.png')
	
	moveDown:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
		iconData.ypos = iconData.ypos + 1
		_fctUpdateIcon()
		editYPos:SetText(tostring(iconData.ypos))
	end, moveDown:GetName() .. '.UI.Input.Mouse.Left.Click')
	
	moveLeft = EnKai.uiCreateFrame('nkTexture', name ..'.moveLeft', content)
	moveLeft:SetPoint("TOPLEFT", positionLabel, "BOTTOMLEFT", 0, 35)
	moveLeft:SetTextureAsync('EnKai', 'gfx/icons/small-arrowLeft.png')
	
	moveLeft:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
		iconData.xpos = iconData.xpos - 1
		if iconData.xpos < 1 then iconData.xpos = 1 end
		_fctUpdateIcon()
		editXPos:SetText(tostring(iconData.xpos))
	end, moveLeft:GetName() .. '.UI.Input.Mouse.Left.Click')
	
	moveRight = EnKai.uiCreateFrame('nkTexture', name ..'.moveRight', content)
	moveRight:SetPoint("CENTERLEFT", editYPos, "CENTERRIGHT", 10, 0)
	moveRight:SetTextureAsync('EnKai', 'gfx/icons/small-arrowRight.png')
	
	moveRight:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
		iconData.xpos = iconData.xpos + 1
		_fctUpdateIcon()
		editXPos:SetText(tostring(iconData.xpos))
	end, moveRight:GetName() .. '.UI.Input.Mouse.Left.Click')
	
	editXPos:SetPoint("CENTERLEFT", moveLeft, "CENTERRIGHT", 10 , 0)
	editXPos:SetWidth(50)
	
	editYPos:SetPoint("CENTERLEFT", slash, "CENTERRIGHT", 10 , 0)
	editYPos:SetWidth(50)
	
	slash:SetPoint("CENTERLEFT", editXPos, "CENTERRIGHT", 5 , 0)
	slash:SetText('/')
	
	deleteButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.deleteButton', content)
	deleteButton:SetPoint("TOPRIGHT", editLabel, "BOTTOMRIGHT", 0, 6)
	deleteButton:SetText(privateVars.langTexts.delete)
	deleteButton:SetVisible(false)
	deleteButton:SetWidth(150)
	deleteButton:SetScale(.8)
	deleteButton:SetColor(.8, 0, 0)
	deleteButton:SetBorderColor(.6, 0, 0)
	deleteButton:SetIcon("EnKai", "gfx/icons/minus.png")
	
	deleteButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
		iconEdit:RemoveIcon()
	end, deleteButton:GetName() .. ".Event.UI.Input.Mouse.Left.Click")
	
	updateButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.updateButton', content)
	updateButton:SetPoint("CENTERTOP", deleteButton, "CENTERBOTTOM", 0, 10)
	updateButton:SetText(privateVars.langTexts.update)
	updateButton:SetVisible(false)
	updateButton:SetWidth(150)
	updateButton:SetScale(.8)
	updateButton:SetIcon("EnKai", "gfx/icons/circle.png")
	
	updateButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
		--print ('---- update ----')
		_fctReadConfig()
		_fctUpdateIcon()
	end, updateButton:GetName() .. ".UI.Input.Mouse.Left.Click")
	
	iconEdit:SetPoint("TOPLEFT", parent, "TOPLEFT")
	iconEdit:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
		
	content:SetPoint("TOPLEFT", iconEdit, "TOPLEFT")
	content:SetPoint("BOTTOMRIGHT", iconEdit, "BOTTOMRIGHT")
	content:SetLayer(2)
		
	function iconEdit:SetIcon()
		
		local rbSet = _internal.getSetByType (setType, set)
		
		local thisIcon = uiElements.icons[rbSet.icons[key].uiId]
		thisIcon:SetDragable(true)
		
		deleteButton:SetVisible(true)
		updateButton:SetVisible(true)
		
		Command.Event.Detach(privateVars.events[thisIcon:GetName()].Moved, nil, thisIcon:GetName() .. '.Moved')
		
		Command.Event.Attach(privateVars.events[thisIcon:GetName()].Moved, function (_, newValue)
		
			iconData.xpos = math.floor(thisIcon:GetLeft())
			iconData.ypos = math.floor(thisIcon:GetTop())
			
			iconEdit:SetConfig()
			
		end, thisIcon:GetName() .. '.Moved')
	end
	
	function iconEdit:SetConfig(newIconData)
		
		if newIconData ~= nil then iconData = newIconData end
		
		--iconActiveCB:SetChecked()
		
		local rbSet = _internal.getSetByType (setType, set)
		local trigger = rbSet.trigger[key]

		iconActiveCB:SetChecked(trigger.active)
		
		showIfRB:SetSelectedValue(trigger.showIfActive or false)
		
		showStackRB:SetSelectedValue(trigger.stackTrigger or "na")
		stackCountSlider:AdjustValue(trigger.stackCounter or 0)
		
		if trigger.sType == 'cooldown' then
			showStackRB:SetActive(false)
			stackCountSlider:SetActive(false)
		else
			showStackRB:SetActive(true)
			stackCountSlider:SetActive(true)
		end
		
		useDefaultsCB:SetChecked(iconData.useDefaults)
		showLabelCB:SetChecked(iconData.showLabel)
		showBorderCB:SetChecked(iconData.showBorder)
		showTimerCB:SetChecked(iconData.showTimer)
		showStackCB:SetChecked(iconData.showStack)
		
		labelColor:SetColor(iconData.labelColor[1], iconData.labelColor[2], iconData.labelColor[3], iconData.labelColor[4])
		borderColor:SetColor(iconData.borderColor[1], iconData.borderColor[2], iconData.borderColor[3], iconData.borderColor[4])
		timerColor:SetColor(iconData.timerColor[1], iconData.timerColor[2], iconData.timerColor[3], iconData.timerColor[4])
		timerOutlineColor:SetColor(iconData.timerOutlineColor[1], iconData.timerOutlineColor[2], iconData.timerOutlineColor[3], 1)
		stackColor:SetColor(iconData.stackColor[1], iconData.stackColor[2], iconData.stackColor[3], iconData.stackColor[4])
		
		sliderScale:AdjustValue(iconData.scale)
		sliderwarnDurationLessThan:AdjustValue(iconData.warnDurationLessThan)
		
		editLabel:SetText(iconData.label)
		
		_fctSetImage (iconData.textureType, iconData.texturePath)
		
		editXPos:SetText(tostring(math.floor(iconData.xpos)))
		editYPos:SetText(tostring(math.floor(iconData.ypos)))
			
	end
	
	function iconEdit:RemoveIcon()

		local rbSet = _internal.getSetByType (setType, set)
		local thisIcon = uiElements.icons[rbSet.icons[key].uiId]
		
		thisIcon:SetVisible(false)
		thisIcon:SetDragable(false)
		
		Command.Event.Detach(privateVars.events[thisIcon:GetName()].Moved, nil, thisIcon:GetName() .. '.Moved')
		
		rbSet.trigger[key] = nil
		rbSet.icons[key] = nil
		
		iconEdit:SetVisible(false)
		
		parent:rebuildButtons()
		parent:updateButtons()
		
	end
	
	
	function iconEdit:SetKey(newKey) key = newKey end
	function iconEdit:SetSetType(newSetType) setType = newSetType end
	function iconEdit:SetSet(newSet) set = newSet end
	function iconEdit:SetUnitType(newUnitType) unitType = newUnitType end
	function iconEdit:SetBuffType(newBuffType) buffType = newBuffType end
		
	return iconEdit
	
end
