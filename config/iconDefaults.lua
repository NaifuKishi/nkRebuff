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

function _ui.ConfigTabIconDefaults (parent)

	local name = parent:GetName().. '.iconDefaults'

	local iconDefaults = EnKai.uiCreateFrame('nkFrame', name, parent)
	local labelDesign, labelFunctionality, labelGlobal, shortLabelsCheckbox, selectEffect
	
	local showLabelCheckbox, showBorderCheckbox, showTimerCheckbox, showStackLabel, showStackHint, timerOutlineLabel
	local labelColor, borderColor, timerColor, timerOutlineColor, stackColor, sliderScale, sliderwarnDurationLessThan	
	local updateButton
	
	function iconDefaults:build()
	
		labelDesign = EnKai.uiCreateFrame("nkText", name .. '.labelDesign', iconDefaults)
	
		showLabelCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. '.showLabelCheckbox', iconDefaults)
		showBorderCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. '.showBorderCheckbox', iconDefaults)
		showTimerCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. '.showTimerCheckbox', iconDefaults)
		timerOutlineLabel = EnKai.uiCreateFrame("nkText", name .. '.timerOutlineLabel', iconDefaults)
		showStackLabel = EnKai.uiCreateFrame("nkText", name .. '.showStackLabel', iconDefaults)
		
		showStackHint = EnKai.uiCreateFrame("nkInfoText", name .. '.showStackHint', iconDefaults)
		
		labelColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.labelColor', iconDefaults)
		borderColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.borderColor', iconDefaults)
		timerColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.timerColor', iconDefaults)
		timerOutlineColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.timerOutlineColor', iconDefaults)
		stackColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.stackColor', iconDefaults)
		
		labelFunctionality = EnKai.uiCreateFrame("nkText", name .. '.labelFunctionality', iconDefaults)
		
		sliderScale = EnKai.uiCreateFrame("nkSlider", name .. '.sliderScale', iconDefaults)	
		sliderwarnDurationLessThan = EnKai.uiCreateFrame("nkSlider", name .. '.sliderwarnDurationLessThan', iconDefaults)	
		
		labelGlobal = EnKai.uiCreateFrame("nkText", name .. '.labelGlobal', iconDefaults)
		shortLabelsCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. '.shortLabelsCheckbox', iconDefaults)
		selectEffect = EnKai.uiCreateFrame("nkCombobox", name .. '.selectEffect', iconDefaults)	
		
		updateButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.updateButton', iconDefaults)
			
		labelDesign:SetPoint("TOPLEFT", iconDefaults, "TOPLEFT")
		labelDesign:SetEffectGlow({ offsetX = 2, offsetY = 2})
		labelDesign:SetText(privateVars.langTexts.design)
		labelDesign:SetFontSize(16)
		labelDesign:SetFontColor(1, 1, 1, 1)
			
		showLabelCheckbox:SetPoint("TOPLEFT", labelDesign, "BOTTOMLEFT", 0, 10)	
		showLabelCheckbox:SetText(privateVars.langTexts.showLabel)
		showLabelCheckbox:SetChecked(nkRBConfig.iconDefaults.showLabel)
		showLabelCheckbox:SetWidth(150)
		
		Command.Event.Attach(EnKai.events[name .. '.showLabelCheckbox'].CheckboxChanged, function (_, newValue)		
			nkRBConfig.iconDefaults.showLabel = newValue 
		end, name .. '.showLabelCheckbox.CheckboxChanged')
		
		showBorderCheckbox:SetPoint("TOPLEFT", showLabelCheckbox, "BOTTOMLEFT", 0, 10)
		showBorderCheckbox:SetText(privateVars.langTexts.showBorder)
		showBorderCheckbox:SetChecked(nkRBConfig.iconDefaults.showBorder)
		showBorderCheckbox:SetWidth(150)
		
		Command.Event.Attach(EnKai.events[name .. '.showBorderCheckbox'].CheckboxChanged, function (_, newValue)		
			nkRBConfig.iconDefaults.showBorder = newValue 
		end, name .. '.showBorderCheckbox.CheckboxChanged')
		
		showTimerCheckbox:SetPoint("TOPLEFT", showBorderCheckbox, "BOTTOMLEFT", 0, 10)
		showTimerCheckbox:SetText(privateVars.langTexts.showTimer)
		showTimerCheckbox:SetChecked(nkRBConfig.iconDefaults.showTimer)
		showTimerCheckbox:SetWidth(150)
		
		Command.Event.Attach(EnKai.events[name .. '.showTimerCheckbox'].CheckboxChanged, function (_, newValue)		
			nkRBConfig.iconDefaults.showTimer = newValue 
		end, name .. '.showTimerCheckbox.CheckboxChanged')
		
		showStackLabel:SetPoint("TOPLEFT", showTimerCheckbox, "BOTTOMLEFT", 0, 7)
		showStackLabel:SetText(privateVars.langTexts.showStack)
		showStackLabel:SetWidth(150)
				
		labelColor:SetPoint("CENTERLEFT", showLabelCheckbox, "CENTERRIGHT", 20, 0 )
		labelColor:SetWidth(80)
		labelColor:SetHeight(15)
		labelColor:SetText(privateVars.langTexts.color)
		labelColor:SetColor(nkRBConfig.iconDefaults.labelColor[1], nkRBConfig.iconDefaults.labelColor[2], nkRBConfig.iconDefaults.labelColor[3], 1)
		labelColor:SetLayer(2)
		
		Command.Event.Attach(EnKai.events[name .. '.labelColor'].ColorChanged, function (_, r, g, b, a)		
			nkRBConfig.iconDefaults.labelColor = { r, g, b, a}
		end, name .. ".labelColor.ColorChanged")
		
		borderColor:SetPoint("CENTERLEFT", showBorderCheckbox, "CENTERRIGHT", 20, 0)
		borderColor:SetWidth(80)
		borderColor:SetHeight(15)
		borderColor:SetText(privateVars.langTexts.color)
		borderColor:SetColor(nkRBConfig.iconDefaults.borderColor[1], nkRBConfig.iconDefaults.borderColor[2], nkRBConfig.iconDefaults.borderColor[3], 1)
		borderColor:SetLayer(2)
		
		Command.Event.Attach(EnKai.events[name .. '.borderColor'].ColorChanged, function (_, r, g, b, a)		
			nkRBConfig.iconDefaults.borderColor = { r, g, b, a}
		end, name .. ".borderColor.ColorChanged")
		
		timerColor:SetPoint("CENTERLEFT", showTimerCheckbox, "CENTERRIGHT", 20, 0 )
		timerColor:SetWidth(80)
		timerColor:SetHeight(15)
		timerColor:SetText(privateVars.langTexts.color)
		timerColor:SetColor(nkRBConfig.iconDefaults.timerColor[1], nkRBConfig.iconDefaults.timerColor[2], nkRBConfig.iconDefaults.timerColor[3], 1)
		timerColor:SetLayer(2)
		
		Command.Event.Attach(EnKai.events[name .. '.timerColor'].ColorChanged, function (_, r, g, b, a)		
			nkRBConfig.iconDefaults.timerColor = { r, g, b, a}
		end, name .. ".timerColor.ColorChanged")
		
		timerOutlineColor:SetPoint("CENTERLEFT", timerColor, "CENTERRIGHT", 10, 0 )
		timerOutlineColor:SetWidth(15)
		timerOutlineColor:SetHeight(15)
		timerOutlineColor:SetColor(nkRBConfig.iconDefaults.timerOutlineColor[1], nkRBConfig.iconDefaults.timerOutlineColor[2], nkRBConfig.iconDefaults.timerOutlineColor[3], 1)
		timerOutlineColor:SetLayer(2)
		
		Command.Event.Attach(EnKai.events[name .. '.timerOutlineColor'].ColorChanged, function (_, r, g, b, a)   
			nkRBConfig.iconDefaults.timerOutlineColor = { r, g, b, a}
		end, name .. ".timerOutlineColor.ColorChanged")
		
		stackColor:SetPoint("CENTERLEFT", showStackLabel, "CENTERRIGHT", 20, 0 )
		stackColor:SetWidth(80)
		stackColor:SetHeight(15)
		stackColor:SetText(privateVars.langTexts.color)
		stackColor:SetColor(nkRBConfig.iconDefaults.stackColor[1], nkRBConfig.iconDefaults.stackColor[2], nkRBConfig.iconDefaults.stackColor[3], 1)
		stackColor:SetLayer(2)
		
		Command.Event.Attach(EnKai.events[name .. '.stackColor'].ColorChanged, function (_, r, g, b, a)		
			nkRBConfig.iconDefaults.stackColor = { r, g, b, a}
		end, name .. ".stackColor.ColorChanged")
		
		showStackHint:SetPoint("TOPLEFT", showStackLabel, "BOTTOMLEFT", 0, 10)
		showStackHint:SetWidth(350)
		showStackHint:SetHeight(30)		
		showStackHint:SetFontSize(10)		
		showStackHint:SetType('info')
		showStackHint:SetText(privateVars.langTexts.stackHint)
				
		sliderScale:SetPoint("TOPLEFT", showStackHint, "BOTTOMLEFT", 0, 20)
		sliderScale:SetRange(20, 150)
		sliderScale:AdjustValue(nkRBConfig.iconDefaults.scale)
		sliderScale:SetLabelWidth(136)
		sliderScale:SetWidth(236)
		sliderScale:SetText(privateVars.langTexts.scale)
		
		Command.Event.Attach(EnKai.events[name .. '.sliderScale'].SliderChanged, function (_, newValue)		
			nkRBConfig.iconDefaults.scale = newValue
		end, name .. '.sliderScale.SliderChanged')
		
		-- DEFAULTS AFFECTING ICONS EVEN WITH OWN SETTINGS --
		
		labelGlobal:SetPoint("TOPLEFT", iconDefaults, "TOPLEFT", 400, 0)
		labelGlobal:SetEffectGlow({ offsetX = 2, offsetY = 2})
		labelGlobal:SetText(privateVars.langTexts.labelGlobal)
		labelGlobal:SetFontSize(16)
		
		shortLabelsCheckbox:SetPoint("TOPLEFT", labelGlobal, "BOTTOMLEFT", 0, 10)	
		shortLabelsCheckbox:SetWidth(150)
		shortLabelsCheckbox:SetText(privateVars.langTexts.shortLabels)
		shortLabelsCheckbox:SetChecked(nkRBConfig.iconDefaults.shortLabels)
		
		Command.Event.Attach(EnKai.events[name .. '.shortLabelsCheckbox'].CheckboxChanged, function (_, newValue)		
			nkRBConfig.iconDefaults.shortLabels = newValue 
		end, name .. '.shortLabelsCheckbox.CheckboxChanged')

		selectEffect:SetPoint("TOPLEFT", shortLabelsCheckbox, "BOTTOMLEFT", 0, 10 )
		selectEffect:SetWidth(300)
		selectEffect:SetSelection(privateVars.langTexts.effectSelection)
		selectEffect:SetSelectedValue(nkRBConfig.iconDefaults.effect)
		selectEffect:SetLabelWidth(136)
		selectEffect:SetText(privateVars.langTexts.effect)
		selectEffect:SetLayer(1)
		
		Command.Event.Attach(EnKai.events[name .. '.selectEffect'].ComboChanged, function (_, newValue)		
			nkRBConfig.iconDefaults.effect = newValue.value
		end, name .. '.selectEffect.ComboChanged')
		
		labelFunctionality:SetPoint("TOPLEFT", selectEffect, "BOTTOMLEFT", 0, 15)
		labelFunctionality:SetEffectGlow({ offsetX = 2, offsetY = 2})
		labelFunctionality:SetText(privateVars.langTexts.functionality)
		labelFunctionality:SetFontSize(16)
		
		sliderwarnDurationLessThan:SetPoint("TOPLEFT", labelFunctionality, "BOTTOMLEFT", 0, 10)	
		sliderwarnDurationLessThan:SetRange(0, 120)
		sliderwarnDurationLessThan:AdjustValue(nkRBConfig.iconDefaults.warnDurationLessThan)
		sliderwarnDurationLessThan:SetLabelWidth(136)
		sliderwarnDurationLessThan:SetWidth(236)
		sliderwarnDurationLessThan:SetText(privateVars.langTexts.runOutWarning)
		
		Command.Event.Attach(EnKai.events[name .. '.sliderwarnDurationLessThan'].SliderChanged, function (_, newValue)		
			nkRBConfig.iconDefaults.warnDurationLessThan = newValue
		end, name .. '.sliderwarnDurationLessThan.SliderChanged')
		
		updateButton:SetPoint("TOPLEFT", sliderwarnDurationLessThan, "BOTTOMLEFT", 0, 20)
		updateButton:SetText(privateVars.langTexts.update)
		updateButton:SetWidth(200)
		updateButton:SetScale(.8)
		
		updateButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			_internal.UpdateAllIcons()
		end, updateButton:GetName() .. ".LeftClick")	
		
	end
	
	return iconDefaults	
	
end
