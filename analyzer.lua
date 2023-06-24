local addonInfo, privateVars = ...

---------- init namespace ---------

local uiElements	= privateVars.uiElements
local _internal		= privateVars.internal
local _ui			= privateVars.ui
local oFuncs		= privateVars.oFuncs

local oInspectBuffDetail = Inspect.Buff.Detail

---------- init local variables ---------

local _aList = { player = {}, ['player.target'] = {}, focus = {}, ['player.pet'] = {}}
local _analyzerInit = false
local _cloneButton

---------- init variables ---------

---------- local function block ---------

local function _fctProcessBuffAdd (unitType, buffId, bDetails, checkUnitId, unitName)

	local hasAdd = false

	if _aList[unitType] == nil then _aList[unitType] = {} end
	
	if unitName ~= nil then _aList[unitType].name = unitName end

	if _aList[unitType][bDetails.bType] == nil then _aList[unitType][bDetails.bType] = {} end
	
	if _aList[unitType][bDetails.bType][bDetails.typeKey] == nil then
		local buffDetails = EnKai.BuffManager.GetBuffDetails(checkUnitId, buffId)
		
		if buffDetails == nil then 
			buffDetails = oInspectBuffDetail(checkUnitId, buffId)
			if buffDetails == nil then return false end
		end

		_aList[unitType][bDetails.bType][bDetails.typeKey] = { name = buffDetails.name, icon = buffDetails.icon, typeKey = buffDetails.type, ability = buffDetails.abilityNew, duration = buffDetails.duration, stack = bDetails.stack, description = buffDetails.description }
		
		if buffDetails.caster ~= nil then
			_aList[unitType][bDetails.bType][bDetails.typeKey].caster = EnKai.unit.getUnitTypes(buffDetails.caster)
		end
		
		hasAdd = true
	
	elseif bDetails.stack ~= nil and (_aList[unitType][bDetails.bType][bDetails.typeKey].stack == nil or bDetails.stack > _aList[unitType][bDetails.bType][bDetails.typeKey].stack) then
		_aList[unitType][bDetails.bType][bDetails.typeKey].stack = bDetails.stack
		hasAdd = true
	end

	return hasAdd
	
end

local function _fctBuffAdd(_, unit, addon, buffs)
		
	if addon ~= oFuncs.InspectAddonCurrent() then return end
	
	local hasAdd = false
	
	local unitTypes = EnKai.unit.getUnitTypes(unit)
	local unitDetails = EnKai.unit.GetUnitDetail (unit)
	
	for buffId, bDetails in pairs(buffs) do
	
		if bDetails.typeKey == nil then
		else
	
			for _, unitType in pairs(unitTypes) do
				if _fctProcessBuffAdd (unitType, buffId, bDetails, unit) then hasAdd = true end
				
				if unitDetails.relation == 'hostile' then
					if _fctProcessBuffAdd (unitDetails.type, buffId, bDetails, unit, unitDetails.name) then hasAdd = true end
				end
			end
		end
	end
	
	if hasAdd and uiElements.Analyzer ~= nil and uiElements.Analyzer:GetVisible() == true then
		uiElements.Analyzer:rebuildButtons()
		uiElements.Analyzer:updateButtons()
		uiElements.Analyzer:UpdateTargetSelection()
	end
	
end

local function _fctProcessBuffChange(unitType, bDetails)

	local hasChange = false

	if _aList[unitType] ~= nil and _aList[unitType][bDetails.bType] ~= nil and _aList[unitType][bDetails.bType][bDetails.typeKey] ~= nil and bDetails.stack ~= nil then
				
		if _aList[unitType][bDetails.bType][bDetails.typeKey].stack == nil or bDetails.stack > _aList[unitType][bDetails.bType][bDetails.typeKey].stack then
			_aList[unitType][bDetails.bType][bDetails.typeKey].stack = bDetails.stack
			hasChange = true
		end
	end

	return hasChange
	
end

local function _fctBuffChange(_, unit, addon, buffs)

	if addon ~= oFuncs.InspectAddonCurrent() then return end
		
	local unitTypes = EnKai.unit.getUnitTypes(unit)
	local unitDetails = EnKai.unit.GetUnitDetail (unit)	
	
	local hasChange = false
	
	for buffId, bDetails in pairs(buffs) do
		for _, unitType in pairs(unitTypes) do
			if _fctProcessBuffChange(unitType, bDetails) then hasChange = true end
			if _fctProcessBuffChange(unitDetails.type, bDetails) then hasChange = true end
		end
	end
	
	if hasChange and uiElements.Analyzer ~= nil and uiElements.Analyzer:GetVisible() == true then
		uiElements.Analyzer:rebuildButtons()
		uiElements.Analyzer:updateButtons()
	end

end

local function _fctCooldownBegin(_, addon, cooldowns)

	if addon ~= oFuncs.InspectAddonCurrent() then return end
	
	local hasAdd = false
	
	if _aList["player"] == nil then _aList["player"] = {} end
	
	for abilityId, cdDetails in pairs(cooldowns) do
		if _aList.player["cooldown" .. cdDetails.type] == nil then _aList.player["cooldown" .. cdDetails.type] = {} end
		
		if _aList.player["cooldown" .. cdDetails.type][abilityId] == nil then
			local abilityDetails = oFuncs.InspectAbilityNewDetail(abilityId)
			_aList.player["cooldown" .. cdDetails.type][abilityId] = { name = abilityDetails.name, icon = abilityDetails.icon, typeKey = abilityId, ability = abilityId, description = abilityDetails.description }
			hasAdd = true
		end
	end
	
	if hasAdd and uiElements.Analyzer ~= nil and uiElements.Analyzer:GetVisible() == true then
		uiElements.Analyzer:rebuildButtons()
		uiElements.Analyzer:updateButtons()
	end

end

---------- addon internal function block ---------

function _internal.initAnalyzer(flag)

	if flag == true and _analyzerInit == false then
		
		Command.Event.Attach(EnKai.events["EnKai.BuffManager"].Add, _fctBuffAdd, "nkRebuff.Analyzer.EnKai.BuffManager.Add")
		Command.Event.Attach(EnKai.events["EnKai.BuffManager"].Change, _fctBuffChange, "nkRebuff.Analyzer.EnKai.BuffManager.Change")
		Command.Event.Attach(EnKai.events["EnKai.CDManager"].Start, _fctCooldownBegin, "nkRebuff.Analyzer.EnKai.CDManager.Start")
		
		if _aList == nil then
			_aList = { player = {}, ['player.target'] = {}, focus = {}, ['player.pet'] = {}}
		end
		
		EnKai.BuffManager.subscribe("buff",  "*", EnKai.unit.getPlayerDetails().id, "*", 0)
		EnKai.BuffManager.subscribe("debuff", "*", EnKai.unit.getPlayerDetails().id, "*", 0)
		EnKai.cdManager.subscribe("ability", "*")
		
		_analyzerInit = true
			
	elseif flag == false then
		
		Command.Event.Detach(EnKai.events["EnKai.BuffManager"].Add, nil, "nkRebuff.Analyzer.EnKai.BuffManager.Add")
		Command.Event.Detach(EnKai.events["EnKai.CDManager"].Start, nil, "nkRebuff.Analyzer.EnKai.CDManager.Start")
	
		EnKai.BuffManager.unsubscribe("buff", "*")
		EnKai.BuffManager.unsubscribe("debuff", "*")
		EnKai.cdManager.unsubscribe("ability", "*")
		
		_analyzerInit = false
			
	end

end

function _internal.resetAnalyzer()

	_aList = { player = {}, ['player.target'] = {}, focus = {}, ['player.pet'] = {}}
	
end

function _internal.analyzerActive() return _analyzerInit end

function _internal.GetAnalyzerEntry(target, buffType, buffKey)

	return _aList[target][buffType][buffKey]

end

function _ui.ContentButton (name, parent)

	local thisButton, stack, timer, inactive
	local pointFrom, pointObject, pointTo, pointX, pointY
	local thisStack, thisTimer, thisType, thisId

	thisButton = EnKai.uiCreateFrame("nkActionButtonMetro", name, parent)
	thisButton:SetScale(.8)
	thisButton:SetLayer(1)
	thisButton:ShowTint(true)
	thisButton:SetTintColor(0, 0, 0, 0)
	
	stack = EnKai.uiCreateFrame("nkText", name .. ".stack", parent)
	stack:SetLayer(2)
	stack:SetFontSize(14)
	stack:SetFontColor (1,1,1,1)
	stack:SetEffectGlow({ blurX = 4, blurY = 4, colorR = 0, colorG = 0, colorB = 0, colorA = 1, offsetX = 0, offsetY = 0, strength = 4,})
	stack:SetPoint("BOTTOMLEFT", thisButton, "BOTTOMLEFT", 1, 1)
	stack:SetVisible(false)
	
	timer = EnKai.uiCreateFrame("nkText", name .. ".timer", parent)
	timer:SetLayer(2)
	timer:SetFontSize(14)
	timer:SetFontColor (1,1,1,1)
	timer:SetEffectGlow({ blurX = 4, blurY = 4, colorR = 0, colorG = 0, colorB = 0, colorA = 1, offsetX = 0, offsetY = 0, strength = 4,})
	timer:SetPoint("TOPRIGHT", thisButton, "TOPRIGHT", -1, -1)
	timer:SetVisible(false)
	
	inactive = EnKai.uiCreateFrame("nkText", name .. ".inactive", parent)
	inactive:SetLayer(2)
	inactive:SetPoint("CENTER", thisButton, "CENTER")
	inactive:SetText("X")
	inactive:SetFontSize(20)
	inactive:SetFontColor (1, 0, 0, 1)
	inactive:SetEffectGlow({ blurX = 5, blurY = 5, colorR = 0, colorG = 0, colorB = 0, colorA = 1, offsetX = 0, offsetY = 0, strength = 8 })
	inactive:SetVisible(false)
	
		
	function thisButton:SetId(newId) thisId = newId end
	function thisButton:GetId(newId) return thisId end
		
	function thisButton:SetStack(newStack)
	
		thisStack = newStack
	
		if newStack == nil or newStack == 0 then
			stack:SetVisible(false)
		else
			stack:SetText(tostring(newStack))
			stack:SetVisible(true)
		end
	end
	
	function thisButton:SetTimer(newTimer)
	
		thisTimer = newTimer
	
		if newTimer ~= nil and newTimer > 0 then
			timer:SetText(EnKai.tools.seoncdsToText (newTimer))
			timer:SetVisible(true)
		else
			timer:SetVisible(false)
		end
	end
	
	function thisButton:SetType(newType)
	
		thisType = newType
		
		if newType == 'buff' then
			thisButton:SetTintColor(0, 1, 0, .2)
			thisButton:SetBackgroundColor(0, 1, 0, 1)
		elseif newType == 'cooldown' then
			thisButton:SetTintColor(0, 0, 1, .2)
			thisButton:SetBackgroundColor(0, 0, 1, 1)
		elseif newType == 'cooldownABILITY' then
			thisButton:SetTintColor(0, 0, 1, .2)
			thisButton:SetBackgroundColor(0, 0, 1, 1)
		elseif newType == 'cooldownITEM' then
			thisButton:SetTintColor(0, 0, 1, .2)
			thisButton:SetBackgroundColor(0, 0, 1, 1)
		elseif newType == 'debuff' then
			thisButton:SetTintColor(1, 0, 0, .2)
			thisButton:SetBackgroundColor(1, 0, 0, 1)
		end
	end
	
	function thisButton:Clone()
	
		if _cloneButton == nil then 
		
			local cloneName = "nkRebuff.clonedIcon"
		
			_cloneButton = _ui.ContentButton(cloneName, uiElements.context)
			
			_cloneButton:EventAttach( Event.UI.Input.Mouse.Left.Up, function (self)
				if _cloneButton.leftDown ~= true then return end
				_cloneButton.leftDown = false
				Command.Event.Detach(Event.Mouse.Move, nil, _cloneButton:GetName() .. ".Mouse.Moved")
				_cloneButton:SetVisible(false)
				
				local tabPane = uiElements.configUI:GetTabPane()
				tabPane:GetPaneInfo()[tabPane:GetActivePane()].frame:CheckDrop(_cloneButton)
				
			end, cloneName .. "Left.Up")
			
		end
		
		local addon, texture = thisButton:GetTexture()
		local target, buffType, key, unitId, unitName = thisButton:GetValue('buffTarget'), thisButton:GetValue('buffType'), thisButton:GetValue('buffKey'), thisButton:GetValue('buffUnitId'), thisButton:GetValue('buffUnitName')
		
		_cloneButton:SetTexture(addon, texture)
		_cloneButton:SetStack(thisTack)
		_cloneButton:SetTimer(thisTimer)
		_cloneButton:SetType(thisType)
		
		_cloneButton:SetValue('buffTarget', target)
		_cloneButton:SetValue('buffType', buffType)
		_cloneButton:SetValue('buffKey', key)
		_cloneButton:SetValue('buffUnitId', unitId)
		_cloneButton:SetValue('buffUnitName', unitName)
		
		_cloneButton:SetVisible(true)
		
		local mouseData = oFuncs.InspectMouse()
		
		_cloneButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mouseData.x, mouseData.y)
		
		_cloneButton.leftDown = true
		_cloneButton.originalXDiff = mouseData.x - _cloneButton:GetLeft()
		_cloneButton.originalYDiff = mouseData.y - _cloneButton:GetTop()
		
		local function _mouseMoved(_, x, y)
			if _cloneButton.leftDown ~= true then return end
			_cloneButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - _cloneButton.originalXDiff, y - _cloneButton.originalYDiff)
		end
		
		Command.Event.Attach(Event.Mouse.Move, _mouseMoved, _cloneButton:GetName() .. ".Mouse.Moved")
		
	end
	
	function thisButton:SetInactive(flag)
		inactive:SetVisible(flag)
	end
	
	local oSetVisible = thisButton.SetVisible
	
	function thisButton:SetVisible(flag)
		oSetVisible(self, flag)
		stack:SetVisible(flag)
		timer:SetVisible(flag)
	end
	
	return thisButton
	
end

function _ui.Analyzer()

	local name = "nkRebuff.Analyzer"
	
	local analyzer, scrollPane, content, targetSelect, typeSelect
	
	local buttons = {}
	
	analyzer = EnKai.uiCreateFrame("nkWindowMetro", name, privateVars.uiElements.context)
	analyzer:SetTitle("nkRebuff Analyzer")
	analyzer:SetWidth(350)
	analyzer:SetHeight(390)
	analyzer:SetDragable(false)
	analyzer:SetPoint("TOPRIGHT", uiElements.configUI, "TOPLEFT")
	
	targetSelect = EnKai.uiCreateFrame("nkComboBox", name .. '.targetSelect', analyzer:GetContent())
	targetSelect:SetSelection(privateVars.langTexts.targetSelectList)
	targetSelect:SetSelectedValue('player')
	targetSelect:SetText(privateVars.langTexts.targetSelect)
	targetSelect:SetLabelWidth(100)
	targetSelect:SetWidth(300)
	targetSelect:SetLayer(9)
	targetSelect:SetPoint("TOPLEFT", analyzer:GetContent(), "TOPLEFT", 10, 20)
	
	Command.Event.Attach(EnKai.events[targetSelect:GetName()].ComboChanged, function()
	
		analyzer:rebuildButtons()
		analyzer:updateButtons()
	
	end, targetSelect:GetName()..".ComboChanged")
	
	scrollPane = EnKai.uiCreateFrame("nkScrollPane", name .. '.scrollPane', analyzer:GetContent())
	scrollPane:SetPoint("TOPLEFT", targetSelect, "BOTTOMLEFT", 0, 20)
	scrollPane:SetWidth(337)
	scrollPane:SetHeight(283)
	scrollPane:SetColor({r = 0.153, g = 0.314, b = 0.490, a = 1})
	
	scrollPane:SetColorInner({r = 0, g = 0, b = 0, a = 1})
	scrollPane:SetColorHighlight({r = 0.153, g = 0.314, b = 0.490, a = 1})
	scrollPane:SetLayer(1)
		
	content = EnKai.uiCreateFrame('nkFrame', name .. '.content', scrollPane)
	content:SetWidth(scrollPane:GetWidth())
	--content:SetBackgroundColor(1,1,1,1)
	
	local function _fctGetTriggerList()
	
		local triggerList = {}
		for aType, aDetails in pairs(_aList[targetSelect.GetSelectedValue()]) do
		
			if aType ~= 'name' then
			
				for key, v in pairs(aDetails) do
					local name = ""
					local details = _internal.GetAnalyzerEntry(targetSelect.GetSelectedValue(), aType, key)
					if details ~= nil then name = details.name end
					table.insert(triggerList, { aType = aType, name = name, key = key, details = v})
				end
				
			end
		end
	
		return triggerList
	
	end
	
	function analyzer:rebuildButtons()
	
		local buttonCount, buttonsPerRow = #_fctGetTriggerList(), 8
		if buttonCount < 56 then buttonCount = 56 end

		buttonCount = (math.floor(buttonCount / buttonsPerRow) + 1 ) * buttonsPerRow
		
		local height = math.floor(buttonCount / buttonsPerRow) * 40.4
		if math.floor(buttonCount / buttonsPerRow) ~= buttonCount / buttonsPerRow then height = height + 40.4 end
		
		content:SetHeight(height) 
	  
		local value = scrollPane:GetLanePosition()
		scrollPane:SetContent(content)
		if value ~= nil then scrollPane:SetLanePosition(value) end
		
		local from, object, to, x, y = "TOPLEFT", content, "TOPLEFT", 0, 1
		local firstObject = nil
	  
		for idx = 1, buttonCount, 1 do
			local thisButton
			if idx > #buttons then
				thisButton = _ui.ContentButton(name .. '.button.' .. idx, content)
				
				thisButton:EventAttach(Event.UI.Input.Mouse.Left.Down, function (self)
					if thisButton:GetValue("buffKey") == nil then return end
					if uiElements.configUI:GetTabPane():GetActivePane() ~= 3 then return end
					thisButton:Clone()
				end, thisButton:GetName() .. '.UI.Input.Mouse.Left.Down')
				
				table.insert(buttons, thisButton)
			else
				thisButton = buttons[idx]
			end
			
			thisButton:SetPoint(from, object, to, x, y)
			
			from, object, to, x, y = "TOPLEFT", thisButton, "TOPRIGHT", 2, 0
			if math.floor(idx/buttonsPerRow) == idx/buttonsPerRow then
				from, object, to, x, y = "TOPLEFT", firstObject, "BOTTOMLEFT", 0, 2
			end
			
			if idx == 1 or math.floor((idx-1)/buttonsPerRow) == (idx-1) / buttonsPerRow then firstObject = thisButton end
			
		end
	end
	
	function analyzer:updateButtons()
		
		local count = 1
		
		local triggerList = _fctGetTriggerList()
		
		table.sort (triggerList, function(a, b)
			if a.aType ~= b.aType then
				return a.aType < b.aType
			end
			
			return a.name < b.name
			
		end)
		
		--for id, triggerDetails in pairs(rbSet.trigger) do
		for idx = 1, #triggerList, 1 do
			local key = triggerList[idx].key
			local v = triggerList[idx].details
			local aType = triggerList[idx].aType
		
			buttons[count]:SetType(aType)
			buttons[count]:SetStack(v.stack)
			buttons[count]:SetTimer(v.duration)
			buttons[count]:SetValue('buffKey', key)
			buttons[count]:SetValue('buffType', aType)
			
			if _aList[targetSelect.GetSelectedValue()].name == nil then
				buttons[count]:SetValue('buffTarget', targetSelect.GetSelectedValue())
				buttons[count]:SetValue('buffUnitId', nil)
				buttons[count]:SetValue('buffUnitName', nil)
			else
				buttons[count]:SetValue('buffTarget', 'player.target')
				buttons[count]:SetValue('buffUnitId', targetSelect.GetSelectedValue())
				buttons[count]:SetValue('buffUnitName', _aList[targetSelect.GetSelectedValue()].name)
			end
			
			buttons[count]:SetTexture("Rift", v.icon)
			
			local details = _internal.GetAnalyzerEntry(targetSelect.GetSelectedValue(), aType, key)
			if details ~= nil then
				EnKai.ui.attachGenericTooltip (buttons[count], details.name, details.description)
			else
				EnKai.ui.attachAbilityTooltip (buttons[count], v.ability)
			end
			
			count = count + 1
		end
		
		if count <= #buttons then
			for idx = count, #buttons, 1 do
				buttons[idx]:ClearTexture()
				buttons[idx]:SetTimer(nil)
				buttons[idx]:SetStack(nil)
				buttons[idx]:SetType(nil)
				buttons[idx]:SetValue('buffKey', nil)
				buttons[idx]:SetValue('buffType', nil)
				buttons[idx]:SetValue('buffTarget', nil)
				buttons[idx]:SetValue('buffUnitId', nil)
				buttons[idx]:SetValue('buffUnitName', nil)
				buttons[idx]:SetTintColor(0, 0, 0, 0)
				buttons[idx]:SetBackgroundColor(0.153, 0.314, 0.490, 1)
				
				EnKai.ui.attachGenericTooltip (buttons[count], nil, nil)
				EnKai.ui.attachAbilityTooltip (buttons[idx], nil)
			end
		end
		
	end
	
	local oSetVisible = analyzer.SetVisible
	
	function analyzer:SetVisible(flag)
		if flag == true then _internal.initAnalyzer(true) end
		
		analyzer:rebuildButtons()
		analyzer:updateButtons()
		analyzer:UpdateTargetSelection()
		
		oSetVisible(self, flag)
	end
	
	function analyzer:UpdateTargetSelection()
	
		local selection = EnKai.tools.table.copy(privateVars.langTexts.targetSelectList)
		
		for key, details in pairs(_aList) do
			if details.name ~= nil then
				table.insert(selection, { value = key, label = details.name })
			end
		end
		
		targetSelect:SetSelection(selection)
	
	end
	
	--analyzer:rebuildButtons()
	--analyzer:updateButtons()
	--analyzer:UpdateTargetSelection()
	
	EnKai.cdManager.init()
	EnKai.BuffManager.init()
	
	return analyzer

end