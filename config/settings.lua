local addonInfo, privateVars = ...
 
---------- init namespace ---------

local data			= privateVars.data
local uiElements	= privateVars.uiElements
local _internal		= privateVars.internal
local _events		= privateVars.events
local _ui			= privateVars.ui
local oFuncs		= privateVars.oFuncs

---------- init local variables ---------

---------- init variables ---------

---------- local function block ---------

---------- addon internal function block ---------

function _ui.ConfigTabSettings (parent)

	local name = parent:GetName().. '.settings'

	local tabPane = EnKai.uiCreateFrame('nkFrame', name, parent)
	
	local labelBasic, activeCheckbox, lockedCheckbox, labelFunctions, showOnlyInCombatCheckbox, autoRoleSwitchCheckbox, gcdSlider 
	local setSelectLabel, setMainSelect, editMainIcon, editMainSetName, roleSelect, addButton, removeButton, copySetButton, labelBuffButton, bbDisplaySelect, bbScaleSlider
	local usePluginCheckbox, setSubSelect, editSubIcon, editSubSetName, addSubButton, removeSubButton, copySubSetButton
	
	-- main set functions
	
	local function _fctRemoveMainSet()
		if #nkRBSetMain == 1 then 
			EnKai.ui.messageDialog(privateVars.langTexts.messages.cannotRemoveLastSet)
		else
			local funcYes = function () 
				_internal.activateSet("mainSet", 1)
				
				table.remove (nkRBSetMain, setMainSelect:GetSelectedValue())
				tabPane:UpdateMainSetSelectValues()
				setMainSelect:SetSelectedValue(1)
			end
			
			EnKai.ui.confirmDialog(privateVars.langTexts.messages.removeCurrentSet, funcYes)
		end
	end
	
	local function _fctAddMainSet()
	
		local noOfSets = #nkRBSetMain
		table.insert(nkRBSetMain, { name = "default", role = 0, trigger = {}, icons = {} } )
		
		nkRBSetMain[noOfSets+1].name = string.format(privateVars.langTexts.genericSettings.newSetName, noOfSets+1)
		nkRBSetMain[noOfSets+1].role = 0
		
		tabPane:UpdateMainSetSelectValues()
		setMainSelect:SetSelectedValue(noOfSets+1)
		
		_internal.activateSet("mainSet", #nkRBSetMain)
	end
	
	local function _fctCopyMainSet()
		local noOfSets = #nkRBSetMain
		local newSet = EnKai.tools.table.copy (nkRBSetMain[setMainSelect:GetSelectedValue()])
		
		newSet.name = string.format(privateVars.langTexts.genericSettings.copiedSetName, nkRBSetMain[setMainSelect:GetSelectedValue()].name)
		
		table.insert ( nkRBSetMain, newSet)
		
		tabPane:UpdateMainSetSelectValues()
		
		setMainSelect:SetSelectedValue(#nkRBSetMain)
		
		_internal.activateSet("mainSet", #nkRBSetMain)
	end
	
	-- sub set functions
	
	local function _fctRemoveSubSet()
	
		if setSubSelect:GetSelectedValue() == 0 then return end
	
		if #nkRBSetSub == 1 then 
			EnKai.ui.messageDialog(privateVars.langTexts.messages.cannotRemoveLastSet)
		else
			local funcYes = function () 
				_internal.activateSet("subSet", nil)
				
				table.remove (nkRBSetSub, setSubSelect:GetSelectedValue())
				tabPane:UpdateSubSetSelectValues()
				setSubSelect:SetSelectedValue(0)				
			end
			
			EnKai.ui.confirmDialog(privateVars.langTexts.messages.removeCurrentSet, funcYes)
		end
	end
	
	local function _fctAddSubSet()
		local noOfSets = #nkRBSetSub
		table.insert(nkRBSetSub, { name = "default", trigger = {}, icons = {} })
		
		nkRBSetSub[noOfSets+1].name = string.format(privateVars.langTexts.genericSettings.newSetName, noOfSets+1)
		nkRBSetSub[noOfSets+1].role = 0
		
		tabPane:UpdateSubSetSelectValues()
		setSubSelect:SetSelectedValue(#nkRBSetSub)
		
		_internal.activateSet("subSet", #nkRBSetSub)
	end
	
	local function _fctCopySubSet()
	
		if setSubSelect:GetSelectedValue() == 0 then return end
	
		local noOfSets = #nkRBSetSub
		local newSet = EnKai.tools.table.copy (nkRBSetSub[setSubSelect:GetSelectedValue()])
		
		newSet.name = string.format(privateVars.langTexts.genericSettings.copiedSetName, nkRBSetSub[setSubSelect:GetSelectedValue()].name)
		
		table.insert ( nkRBSetSub, newSet)
		
		tabPane:UpdateSubSetSelectValues()
		setSubSelect:SetSelectedValue(#nkRBSetSub)
		
		_internal.activateSet("subSet", #nkRBSetSub)
	end
	
	function tabPane:build ()
	
		labelBasic = EnKai.uiCreateFrame("nkText", name .. '.labelBasic', tabPane)
		labelBasic:SetPoint("TOPLEFT", tabPane, "TOPLEFT")
		labelBasic:SetEffectGlow({ offsetX = 2, offsetY = 2})
		labelBasic:SetText(privateVars.langTexts.genericSettings.basic)
		labelBasic:SetFontSize(16)
			
		usePluginCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. '.usePluginCheckbox', tabPane)
		usePluginCheckbox:SetPoint("TOPLEFT", labelBasic, "BOTTOMLEFT", 0, 10)
		usePluginCheckbox:SetWidth(200)
		usePluginCheckbox:SetText(privateVars.langTexts.genericSettings.usePluginCheckbox)
		usePluginCheckbox:SetChecked(nkRBConfig.nkPanel or true)
		usePluginCheckbox:SetLabelInFront(true)
		
		Command.Event.Attach(EnKai.events[usePluginCheckbox:GetName()].CheckboxChanged, function (_, newValue)
			nkRBConfig.nkPanel = newValue
			if nkPanel ~= nil then
				if uiElements.panel ~= nil then
					nkPanel.api.togglePanel('nkRebuff', newValue)
				elseif newValue == true then
					local items = {}
					for idx = 1, #nkRBSetMain, 1 do
						table.insert (items, { label = nkRBSetMain[idx].name, callBack = function() _internal.activateSet ("mainSet", idx) end })
					end
					
					table.insert(items, { seperator = true })
					
					for idx = 1, #nkRBSetSub, 1 do
						table.insert (items, { label = nkRBSetSub[idx].name, callBack = function() _internal.activateSet ("subSet", idx) end })
					end
					
					uiElements.panel = _internal.nkPanelPlugin(items)
					nkPanel.api.registerPlugin('nkRebuff', uiElements.panel)
					uiElements.panel:SetTitle(nkRBSetMain[nkRBConfig.activeSet].name)
				end
			end
		end, usePluginCheckbox:GetName() .. ".CheckboxChanged")
		
		showOnlyInCombatCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. '.showOnlyInCombatCheckbox', tabPane)	
		showOnlyInCombatCheckbox:SetPoint("TOPLEFT", usePluginCheckbox, "BOTTOMLEFT", 0, 12)
		showOnlyInCombatCheckbox:SetWidth(200)
		showOnlyInCombatCheckbox:SetText(privateVars.langTexts.genericSettings.cbCombat)
		showOnlyInCombatCheckbox:SetChecked(nkRBConfig.combatOnly)
		showOnlyInCombatCheckbox:SetLabelInFront(true)
		
		Command.Event.Attach(EnKai.events[showOnlyInCombatCheckbox:GetName()].CheckboxChanged, function (_, newValue)
			nkRBConfig.combatOnly = newValue 
			_internal.activateSet('mainSet', nkRBConfig.activeSet)
			--_internal.activateSet('subSet', data.activeSubSet)
		end, showOnlyInCombatCheckbox:GetName() .. ".CheckboxChanged")
		
		autoRoleSwitchCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. '.autoRoleSwitchCheckbox', tabPane)	
		autoRoleSwitchCheckbox:SetPoint("TOPLEFT", showOnlyInCombatCheckbox, "BOTTOMLEFT", 0, 12	)
		autoRoleSwitchCheckbox:SetWidth(200)
		autoRoleSwitchCheckbox:SetText(privateVars.langTexts.genericSettings.roleSwitch)
		autoRoleSwitchCheckbox:SetChecked(nkRBConfig.autoRoleSwitch)
		autoRoleSwitchCheckbox:SetLabelInFront(true)
				
		Command.Event.Attach(EnKai.events[autoRoleSwitchCheckbox:GetName()].CheckboxChanged, function (_, newValue)		
			nkRBConfig.autoRoleSwitch = newValue 
			if newValue == true then 
				Command.Event.Attach(Event.Unit.Detail.Role, _internal.RoleChange, "nkRebuff.Unit.Detail.Role")
			else
				Command.Event.Detach(Event.Unit.Detail.Role, nil, "nkRebuff.Unit.Detail.Role")
			end
		end, autoRoleSwitchCheckbox:GetName() .. ".CheckboxChanged")
		
		gcdSlider = EnKai.uiCreateFrame("nkSlider", name .. '.gcdSlider', tabPane)
		gcdSlider:SetPoint("TOPLEFT", autoRoleSwitchCheckbox, "BOTTOMLEFT", 0, 11)
		gcdSlider:SetWidth(300)
		gcdSlider:SetRange(0, 1.5)
		gcdSlider:SetLabelWidth(187)
		gcdSlider:SetText(privateVars.langTexts.gcd)
		gcdSlider:SetPrecision(0.1)
		gcdSlider:AdjustValue(nkRBConfig.gcd)
		
		Command.Event.Attach(EnKai.events[gcdSlider:GetName()].SliderChanged, function (_, newValue)
			nkRBConfig.gcd = EnKai.tools.math.round(newValue, 1)
			EnKai.cdManager.setGCD(nkRBConfig.gcd)
		end, gcdSlider:GetName() .. ".SliderChanged")
		
		labelBuffButton = EnKai.uiCreateFrame("nkText", name .. '.labelBuffButton', tabPane)
		labelBuffButton:SetPoint("TOPLEFT", gcdSlider, "BOTTOMLEFT", 0, 25)
		labelBuffButton:SetEffectGlow({ offsetX = 2, offsetY = 2})
		labelBuffButton:SetText(privateVars.langTexts.genericSettings.buffButton)
		labelBuffButton:SetFontSize(16)
		labelBuffButton:SetFontColor(1, 1, 1, 1)

		bbDisplaySelect = EnKai.uiCreateFrame("nkCombobox", name .. ".bbDisplaySelect", tabPane)
		bbDisplaySelect:SetPoint("TOPLEFT", labelBuffButton, "BOTTOMLEFT", 0, 10)
		bbDisplaySelect:SetLayer(9)
		bbDisplaySelect:SetWidth(350)
		bbDisplaySelect:SetLabelWidth(187)
		bbDisplaySelect:SetSelection(privateVars.langTexts.genericSettings.bbDisplay)
		bbDisplaySelect:SetSelectedValue(nkRBConfig.buffButton, false)
		bbDisplaySelect:SetText(privateVars.langTexts.genericSettings.showButton)
		
		Command.Event.Attach(EnKai.events[bbDisplaySelect:GetName()].ComboChanged, function (_, newValue)
			
			nkRBConfig.buffButton = newValue.value
			
			if newValue.value  ~= '0' then 
				_internal.buildReBuff()
				_internal.setReBuffMacro(false)
			else
				if uiElements.buffButton ~= nil then uiElements.buffButton:SetVisible(false) end
			end
		end, bbDisplaySelect:GetName() .. ".ComboChanged")
		
		bbScaleSlider = EnKai.uiCreateFrame("nkSlider", name .. '.bbScaleSlider', tabPane)	
		bbScaleSlider:SetPoint("TOPLEFT", bbDisplaySelect, "BOTTOMLEFT", 0, 8)
		bbScaleSlider:SetWidth(300)
		bbScaleSlider:SetRange(20, 150)
		bbScaleSlider:SetLabelWidth(187)
		bbScaleSlider:SetText(privateVars.langTexts.scale)
		bbScaleSlider:SetPrecision(0.1)
		bbScaleSlider:AdjustValue(nkRBConfig.buffButtonScale)
		
		Command.Event.Attach(EnKai.events[bbScaleSlider:GetName()].SliderChanged, function (_, newValue)
			nkRBConfig.buffButtonScale = newValue
			
			if oFuncs.InspectSystemSecure() == true then return end
			
			if uiElements.buffButton ~= nil then uiElements.buffButton:SetScale(nkRBConfig.buffButtonScale/100) end
			if uiElements.buffButtonBar ~= nil then
				local width = 0
				for idx = 1, #uiElements.buffButtonBar.subButtons, 1 do
					uiElements.buffButtonBar.subButtons[idx]:SetScale(nkRBConfig.buffButtonScale/100)
					width = width + uiElements.buffButtonBar.subButtons[idx]:GetWidth()
				end 
				
				uiElements.buffButtonBar:SetHeight(uiElements.buffButtonBar.subButtons[1]:GetHeight())
				uiElements.buffButtonBar:SetWidth(width)
			end			
		end, bbScaleSlider:GetName() .. ".SliderChanged")

		bbHint = EnKai.uiCreateFrame('nkInfoText', name .. '.bbHint', tabPane)
		bbHint:SetPoint("TOPLEFT", bbScaleSlider, "BOTTOMLEFT", 0, 10)
		bbHint:SetFontSize(10)
		bbHint:SetWidth(400)
		bbHint:SetHeight(60)
		bbHint:SetType('info')
		bbHint:SetIconAlign('top')
		bbHint:SetText(privateVars.langTexts.genericSettings.bbHint)
		
		-- SET MANAGEMENT
				
		setSelectLabel = EnKai.uiCreateFrame("nkText", name .. '.setSelectLabel', tabPane)
		setSelectLabel:SetPoint("TOPLEFT", tabPane, "TOPLEFT", 395, 0)
		setSelectLabel:SetText(privateVars.langTexts.genericSettings.sets)
		setSelectLabel:SetEffectGlow({ offsetX = 2, offsetY = 2})
		setSelectLabel:SetFontSize(16)
		
		setMainSelect = EnKai.uiCreateFrame("nkCombobox", name .. ".setMainSelect", tabPane)
		setMainSelect:SetPoint("TOPLEFT", setSelectLabel, "BOTTOMLEFT", 0, 6)
		setMainSelect:SetLayer(9)
		setMainSelect:SetWidth(350)
		setMainSelect:SetLabelWidth(150)
		setMainSelect:SetSelectedValue(nkRBConfig.activeSet, false)
		setMainSelect:SetText(privateVars.langTexts.genericSettings.currentMainSet)
		
		Command.Event.Attach(EnKai.events[setMainSelect:GetName()].ComboChanged, function (_, newValue)
			_internal.activateSet("mainSet", newValue.value)
			roleSelect:SetSelectedValue(nkRBSetMain[newValue.value].role)
		end, setMainSelect:GetName() .. ".ComboChanged")
		
		editMainIcon = EnKai.uiCreateFrame('nkTexture', name .. '.editMainIcon', tabPane)
		editMainIcon:SetTextureAsync("EnKai", "gfx/icons/editPen.png")
		editMainIcon:SetWidth(15)
		editMainIcon:SetHeight(15)
		editMainIcon:SetPoint("CENTERLEFT", setMainSelect, "CENTERRIGHT", 5, 0)
		
		editMainIcon:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			if editMainSetName:GetVisible() == true then
				editMainSetName:SetKeyFocus(false)
				setMainSelect:SetComboVisible(true)
				editMainSetName:SetVisible(false)
			else
				editMainSetName:SetText(setMainSelect:GetSelectedLabel())
				setMainSelect:SetComboVisible(false)
				editMainSetName:SetVisible(true)
			end
		end, editMainIcon:GetName() .. 'UI.INput.Mouse.Left.Click')
		
		editMainSetName = EnKai.uiCreateFrame("nkTextfield", name .. '.editMainSetName', tabPane)	
		editMainSetName:SetVisible(false)
		editMainSetName:SetWidth(200)
		editMainSetName:SetHeight(20)
		editMainSetName:SetText(nkRBConfig.activateSet)
		editMainSetName:SetPoint("TOPRIGHT", setMainSelect, "TOPRIGHT")
		
		Command.Event.Attach(EnKai.events[editMainSetName:GetName()].TextfieldChanged, function ()
			nkRBSetMain[setMainSelect:GetSelectedValue()].name = editMainSetName:GetText()
			tabPane:UpdateMainSetSelectValues()
			setMainSelect:SetComboVisible(true)
			editMainSetName:SetVisible(false)
		end, editMainSetName:GetName() .. '.TextfieldChanged')
		
		local selValues = privateVars.langTexts.genericSettings.selectionRole
		
		local roleList = oFuncs.InspectRoleList()
		
		for k, v in pairs (roleList) do
			local id = string.sub ( k, string.len(k) - 1)
			if id ~= nil then
				table.insert(selValues, { label = v, value = tonumber(id, 16)+1})
			end
		end
		
		roleSelect = EnKai.uiCreateFrame("nkCombobox", name .. ".roleSelect", tabPane)
		roleSelect:SetPoint("TOPLEFT", setMainSelect, "BOTTOMLEFT", 0, 5)
		roleSelect:SetLayer(8)
		roleSelect:SetWidth(350)
		roleSelect:SetLabelWidth(150)
		roleSelect:SetText(privateVars.langTexts.genericSettings.role)
		roleSelect:SetSelection(selValues)
		roleSelect:SetSelectedValue(nkRBSetMain[nkRBConfig.activeSet].role, false)
		
		Command.Event.Attach(EnKai.events[roleSelect:GetName()].ComboChanged, function (_, newValue)
			nkRBSetMain[setMainSelect:GetSelectedValue()].role = newValue.value
		end, roleSelect:GetName() .. ".ComboChanged")
		
		addButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.addButton', tabPane)
		addButton:SetText(privateVars.langTexts.genericSettings.addButton)
		addButton:SetPoint("TOPLEFT", roleSelect, "BOTTOMLEFT", 0, 10)
		addButton:SetWidth(150)
		addButton:SetScale(.8)
		
		addButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			_fctAddMainSet()
		end, addButton:GetName() .. ".UI.Input.Mouse.Left.Click")
		
		removeButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.removeButton', tabPane)
		removeButton:SetText(privateVars.langTexts.genericSettings.removeButton)
		removeButton:SetPoint("CENTERLEFT", addButton, "CENTERRIGHT", 5, 0)
		removeButton:SetWidth(150)
		removeButton:SetScale(.8)
		
		removeButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			_fctRemoveMainSet()
		end, removeButton:GetName() .. ".UI.Input.Mouse.Left.Click")
		
		copySetButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.copySetButton', tabPane)
		copySetButton:SetText(privateVars.langTexts.genericSettings.copySetButton)
		copySetButton:SetPoint("CENTERLEFT", removeButton, "CENTERRIGHT", 5, 0)
		copySetButton:SetWidth(150)
		copySetButton:SetScale(.8)

		copySetButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			_fctCopyMainSet()
		end, copySetButton:GetName() .. ".UI.Input.Mouse.Left.Click")
		
		-- sub set selection
		
		setSubSelect = EnKai.uiCreateFrame("nkCombobox", name .. ".setSubSelect", tabPane)
		setSubSelect:SetPoint("TOPLEFT", addButton, "BOTTOMLEFT", 0, 40)
		setSubSelect:SetLayer(9)
		setSubSelect:SetWidth(350)
		setSubSelect:SetLabelWidth(150)
		setSubSelect:SetSelectedValue(data.activeSubSet or 0, false)
		setSubSelect:SetText(privateVars.langTexts.genericSettings.currentSubSet)
		
		Command.Event.Attach(EnKai.events[setSubSelect:GetName()].ComboChanged, function (_, newValue)
			_internal.activateSet("subSet", newValue.value)
		end, setSubSelect:GetName() .. ".ComboChanged")
		
		editSubIcon = EnKai.uiCreateFrame('nkTexture', name .. '.editSubIcon', tabPane)
		editSubIcon:SetTextureAsync("EnKai", "gfx/icons/editPen.png")
		editSubIcon:SetWidth(15)
		editSubIcon:SetHeight(15)
		editSubIcon:SetPoint("CENTERLEFT", setSubSelect, "CENTERRIGHT", 5, 0)
		
		editSubIcon:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			if editSubSetName:GetVisible() == true then
				editSubSetName:SetKeyFocus(false)
				setSubSelect:SetComboVisible(true)
				editSubSetName:SetVisible(false)
			else
				editSubSetName:SetText(setSubSelect:GetSelectedLabel())
				setSubSelect:SetComboVisible(false)
				editSubSetName:SetVisible(true)
			end
		end, editSubIcon:GetName() .. '.UI.Input.Mouse.Left.Click')
		
		editSubSetName = EnKai.uiCreateFrame("nkTextfield", name .. '.editSubSetName', tabPane)	
		editSubSetName:SetVisible(false)
		editSubSetName:SetWidth(200)
		editSubSetName:SetHeight(20)
		editSubSetName:SetPoint("TOPRIGHT", setSubSelect, "TOPRIGHT")
		
		Command.Event.Attach(EnKai.events[editSubSetName:GetName()].TextfieldChanged, function ()		
			nkRBSetSub[setSubSelect:GetSelectedValue()].name = editSubSetName:GetText()
			tabPane:UpdateSubSetSelectValues()
			setSubSelect:SetComboVisible(true)
			editSubSetName:SetVisible(false)
		end, editSubSetName:GetName() .. '.TextfieldChanged')
		
		addSubButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.addSubButton', tabPane)
		addSubButton:SetText(privateVars.langTexts.genericSettings.addButton)
		addSubButton:SetPoint("TOPLEFT", setSubSelect, "BOTTOMLEFT", 0, 10)
		addSubButton:SetWidth(150)
		addSubButton:SetScale(.8)
		
		addSubButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			_fctAddSubSet()
		end, addSubButton:GetName() .. ".UI.Input.Mouse.Left.Click")
		
		removeSubButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.removeSubButton', tabPane)
		removeSubButton:SetText(privateVars.langTexts.genericSettings.removeButton)
		removeSubButton:SetPoint("CENTERLEFT", addSubButton, "CENTERRIGHT", 5, 0)
		removeSubButton:SetWidth(150)
		removeSubButton:SetScale(.8)
		
		removeSubButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			_fctRemoveSubSet()
		end, removeSubButton:GetName() .. ".UI.Input.Mouse.Left.Click")
		
		copySubSetButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.copySubSetButton', tabPane)
		copySubSetButton:SetText(privateVars.langTexts.genericSettings.copySetButton)
		copySubSetButton:SetPoint("CENTERLEFT", removeSubButton, "CENTERRIGHT", 5, 0)
		copySubSetButton:SetWidth(150)
		copySubSetButton:SetScale(.8)

		copySubSetButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			_fctCopySubSet()
		end, copySubSetButton:GetName() .. ".UI.Input.Mouse.Left.Click")
		
		tabPane:UpdateMainSetSelectValues()
		tabPane:UpdateSubSetSelectValues()
	
	end
	
	function tabPane:UpdateMainSetSelectValues()

		local selection = {}
		
		for idx = 1, #nkRBSetMain, 1 do
			table.insert (selection, { label = nkRBSetMain[idx].name, value = idx })
		end
		
		setMainSelect:SetSelection(selection)		
		
	end
	
	function tabPane:UpdateSubSetSelectValues()

		local selection = {{ label = privateVars.langTexts.noSubSet, value = 0}}
		
		for idx = 1, #nkRBSetSub, 1 do
			table.insert (selection, { label = nkRBSetSub[idx].name, value = idx })
		end
		
		setSubSelect:SetSelection(selection)
		
	end

	
	return tabPane
	
end