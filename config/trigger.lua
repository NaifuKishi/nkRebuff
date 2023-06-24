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

function _ui.ConfigTabTrigger (parent)

	local name = parent:GetName().. '.trackGrid'

	local tabPane = EnKai.uiCreateFrame('nkFrame', name, parent)
	local scrollPane, content, setTypeSelect, iconEdit, targetSelect, setSelect
	
	local isBuilt = false
	local currentIconEdit
	local buttonCount = 40
	local buttons = {}
	
	function tabPane:UpdateTargetSelect(updateSelected)
		
		local selection = EnKai.tools.table.copy(privateVars.langTexts.targetSelectList)
		
		local thisSet
		if setTypeSelect:GetSelectedValue() == 'mainSet' then
			thisSet = nkRBSetMain[setSelect:GetSelectedValue()]
		else
			thisSet = nkRBSetSub[setSelect:GetSelectedValue()]
		end
		
		local nameList = {}
		local checkList = {}
		
		for id, triggerDetails in pairs(thisSet.trigger) do
			if triggerDetails.unitName ~= nil and checkList[triggerDetails.unitName] == nil then
				table.insert(selection, { label = triggerDetails.unitName, value = triggerDetails.unitTypeKey })
				checkList[triggerDetails.unitName] = true
			end
		end
		
		targetSelect:SetSelection(selection)
		
		if updateSelected == false then
			local thisValue = targetSelect:GetSelectedValue()
			for key, value in pairs(selection) do
				if value == thisValue then return end
			end
		end

		targetSelect:SetSelectedValue("player", false)
		
	end
	
	function tabPane:rebuildButtons()
	
		if data.rebuildButtons then return end
	
		data.rebuildButtons = true
	
		local count = 0
		local rbSet
		
		if setTypeSelect:GetSelectedValue() == 'mainSet' then
			rbSet = nkRBSetMain[setSelect:GetSelectedValue()]
		else
			rbSet = nkRBSetSub[setSelect:GetSelectedValue()]
		end
		
		local thisTarget = targetSelect:GetSelectedValue()
		
		for id, triggerDetails in pairs(rbSet.trigger) do
			if triggerDetails.unitType == thisTarget or triggerDetails.unitTypeKey == thisTarget then
				count = count + 1
			end
		end
	
		count = (math.floor(count/8) + 1 ) * 8
		
		local height = math.floor(count / 8) * 38.4
		if math.floor(count / 8) ~= count / 8 then height = height + 38.4 end
		
		content:SetHeight(height) 
	  
		local value = scrollPane:GetLanePosition()
		scrollPane:SetContent(content)
		if value ~= nil then scrollPane:SetLanePosition(value) end
		
		local from, object, to, x, y = "TOPLEFT", content, "TOPLEFT", 0, 0
		local firstObject = nil
      
		for idx = 1, buttonCount, 1 do
			local thisButton
			if idx > #buttons then
				thisButton = _ui.ContentButton (name .. '.button.' .. idx, content)
				table.insert(buttons, thisButton)
				
				Command.Event.Attach(EnKai.events[thisButton:GetName()].Clicked, function (this)
					tabPane:SetIconEdit(thisButton:GetId())
				end, thisButton:GetName() .. '.Clicked')
				
			else
				thisButton = buttons[idx]
			end
			
			thisButton:SetPoint(from, object, to, x, y)
			
			from, object, to, x, y = "TOPLEFT", thisButton, "TOPRIGHT", 2, 0
			if math.floor(idx/8) == idx/8 then
				from, object, to, x, y = "TOPLEFT", firstObject, "BOTTOMLEFT", 0, 2
			end
			
			if idx == 1 or math.floor((idx-1)/8) == (idx-1) / 8 then firstObject = thisButton end
			
		end
		
		data.rebuildButtons = false
		
	end
	
	function tabPane:updateButtons()
	
		if data.updateButtons then return end
	
		data.updateButtons = true
	
		local dataSet, rbSet, namedUnit
		
		if setTypeSelect:GetSelectedValue() == 'mainSet' then
			rbSet = nkRBSetMain[setSelect:GetSelectedValue()]
		else
			rbSet = nkRBSetSub[setSelect:GetSelectedValue()]
		end
		
		local count = 1
		local thisTarget = targetSelect:GetSelectedValue()
		
		local triggerList, abilityMap, abilityList = {}, {}, {}
		for id, triggerDetails in pairs(rbSet.trigger) do
			local cachedData = nkRBCache[_internal.getCacheKey (triggerDetails)]
			
			if cachedData == nil then 
				rbSet.trigger[id] = nil
			else			
				table.insert(triggerList, { tType = triggerDetails.sType, name = cachedData.name, id = id, details = triggerDetails})
				if cachedData.ability ~= nil then
					triggerList[#triggerList].unavailable = true
					abilityMap[cachedData.ability] = #triggerList
					table.insert(abilityList, cachedData.ability)
				end
			end
		end
		
		if #abilityList > 0 then
			local abilityDetails = Inspect.Ability.New.Detail(abilityList)
			for k, v in pairs(abilityDetails) do
				if abilityMap[v.idNew] ~= nil then
					triggerList[abilityMap[v.idNew]].unavailable = nil
				end
			end
		end
		
		table.sort (triggerList, function(a, b)
			if a.tType ~= b.tType then
				return a.tType < b.tType
			end
			
			return a.name < b.name
			
		end)
		
		--for id, triggerDetails in pairs(rbSet.trigger) do
		for idx = 1, #triggerList, 1 do
			local id = triggerList[idx].id
			local triggerDetails = triggerList[idx].details
			
			if triggerDetails.unitType == thisTarget or triggerDetails.unitTypeKey == thisTarget then
			
				local thisIcon = rbSet.icons[id]
				local cachedData = nkRBCache[_internal.getCacheKey (triggerDetails)]
			
				buttons[count]:SetId(id)
				buttons[count]:SetType(triggerDetails.sType)
				buttons[count]:SetTimer(cachedData.duration)
				buttons[count]:SetStack(cachedData.stack)
				buttons[count]:SetTexture("Rift", cachedData.icon)
				
				if triggerList[idx].unavailable then
					buttons[count]:SetInactive(true)
				else
					buttons[count]:SetInactive(false)
				end

				EnKai.ui.attachGenericTooltip (buttons[count], cachedData.name, cachedData.description)
				
				count = count + 1
			end
		end
		
		if count <= #buttons then
			for idx = count, #buttons, 1 do
				buttons[idx]:ClearTexture()
				buttons[idx]:SetTimer(nil)
				buttons[idx]:SetStack(nil)
				buttons[idx]:SetId(nil)
				buttons[idx]:SetType(nil)
				buttons[idx]:SetInactive(false)
				buttons[idx]:SetTintColor(0, 0, 0, 0)
				buttons[idx]:SetBackgroundColor(0.153, 0.314, 0.490, 1)

				EnKai.ui.attachAbilityTooltip (buttons[idx], nil)
			end
		end
		
		data.updateButtons = false

	end
	
	function tabPane:build ()
	
		setTypeSelect = EnKai.uiCreateFrame("nkRadioButton", name .. '.setTypeSelect', tabPane)
		setTypeSelect:SetSelection(privateVars.langTexts.setTypeSelectList)
		setTypeSelect:SetSelectedValue('mainSet')
		setTypeSelect:SetText(privateVars.langTexts.setTypeSelect)
		setTypeSelect:SetLabelWidth(100)
		setTypeSelect:SetWidth(300)
		setTypeSelect:SetLayer(9)
		setTypeSelect:SetPoint("TOPLEFT", tabPane, "TOPLEFT", 0, 5)
		
		Command.Event.Attach(EnKai.events[setTypeSelect:GetName()].RadiobuttonChanged, function()
			
			tabPane:UpdateSetSelect()
			
			_internal.activateSet (setTypeSelect:GetSelectedValue(), setSelect:GetSelectedValue())
			
			tabPane:UpdateTargetSelect()
			tabPane:SetIconEdit()
						
		end, setTypeSelect:GetName()..".RadiobuttonChanged")
		
		setSelect = EnKai.uiCreateFrame("nkComboBox", name .. '.setSelect', tabPane)
		setSelect:SetSelectedValue(nkRBConfig.activeSet, false)
		setSelect:SetText(privateVars.langTexts.setSelect)
		setSelect:SetLabelWidth(100)
		setSelect:SetWidth(300)
		setSelect:SetLayer(8)
		setSelect:SetPoint("TOPLEFT", setTypeSelect, "BOTTOMLEFT", 0, 8)
		
		Command.Event.Attach(EnKai.events[setSelect:GetName()].ComboChanged, function()
		
			_internal.activateSet (setTypeSelect:GetSelectedValue(), setSelect:GetSelectedValue())
		
			tabPane:UpdateTargetSelect()
			tabPane:SetIconEdit()
			tabPane:rebuildButtons()
			tabPane:updateButtons()
		end, setSelect:GetName()..".ComboChanged")
		
		targetSelect = EnKai.uiCreateFrame("nkComboBox", name .. '.targetSelect', tabPane)
		targetSelect:SetSelectedValue('player')
		targetSelect:SetText(privateVars.langTexts.targetSelect)
		targetSelect:SetLabelWidth(100)
		targetSelect:SetWidth(300)
		targetSelect:SetLayer(7)
		targetSelect:SetPoint("TOPLEFT", setSelect, "BOTTOMLEFT", 0, 5)
		
		Command.Event.Attach(EnKai.events[targetSelect:GetName()].ComboChanged, function()
			tabPane:SetIconEdit()
			tabPane:rebuildButtons()
			tabPane:updateButtons()
		end, targetSelect:GetName()..".ComboChanged")
	
		scrollPane = EnKai.uiCreateFrame("nkScrollPane", name .. '.scrollPane', tabPane)
		scrollPane:SetPoint("TOPLEFT", targetSelect, "BOTTOMLEFT", 0, 20)
		scrollPane:SetWidth(330)
		scrollPane:SetHeight(230)
		scrollPane:SetColor({r = 0.153, g = 0.314, b = 0.490, a = 1})
		--scrollPane:SetBackgroundColor(1,1,1,1)
		
		scrollPane:SetColorInner({r = 0, g = 0, b = 0, a = 1})
		scrollPane:SetColorHighlight({r = 0.153, g = 0.314, b = 0.490, a = 1})
		scrollPane:SetLayer(1)
		
		content = EnKai.uiCreateFrame('nkFrame', name .. '.content', scrollPane)
		content:SetWidth(scrollPane:GetWidth())
		
		tabPane:UpdateSetSelect(true)
		tabPane:UpdateTargetSelect()

		isBuilt = true
	end

	function tabPane:SetIconEdit(id)
	
		currentIconEdit = id
	
		if iconEdit == nil then
			EnKai.tools.perf.addToQueue(function()
				iconEdit = _ui.iconEdit (tabPane)
				iconEdit:SetPoint("TOPRIGHT", tabPane, "TOPRIGHT", 0, 0)
				tabPane:SetIconEdit(id)
			end)
			return
		end
		
		if id == nil then
			iconEdit:SetVisible(false)
			return
		end
		
		--_internal.activateSet (setTypeSelect:GetSelectedValue(), setSelect:GetSelectedValue())
		
		iconEdit:SetVisible(true)
	
		iconEdit:SetSet(setSelect:GetSelectedValue())
		iconEdit:SetSetType(setTypeSelect:GetSelectedValue())
		iconEdit:SetKey(id)
		
		local rbSet
		if setTypeSelect:GetSelectedValue() == 'mainSet' then
			rbSet = nkRBSetMain[setSelect:GetSelectedValue()]
		else
			rbSet = nkRBSetSub[setSelect:GetSelectedValue()]
		end
		
		local trigger = rbSet.trigger[id]
		
		local uiIcon = _internal.displayOrCreateIcon (setTypeSelect:GetSelectedValue(), setSelect:GetSelectedValue(), id, trigger, rbSet.icons[id])
		iconEdit:SetIcon()
		iconEdit:SetConfig(rbSet.icons[id])
	end
	
	function tabPane:GetSetSelect() return setSelect end
	
	function tabPane:CheckDrop(dropElement)
		
		local x, y = dropElement:GetLeft(), dropElement:GetTop()
		if x >= scrollPane:GetLeft() and x <= scrollPane:GetLeft() + scrollPane:GetWidth() - dropElement:GetWidth() and y >= scrollPane:GetTop() and y <= scrollPane:GetTop() + scrollPane:GetHeight() - dropElement:GetHeight() then
			
			
			local target, buffType, buffId, unitType = dropElement:GetValue("buffTarget"), dropElement:GetValue("buffType"), dropElement:GetValue("buffKey"), dropElement:GetValue("buffUnitId")
			
			local rbSet
			
			if setTypeSelect:GetSelectedValue() == 'mainSet' then
				rbSet = nkRBSetMain[setSelect:GetSelectedValue()]
			else
				rbSet = nkRBSetSub[setSelect:GetSelectedValue()]
			end
			
			local thisBuffType = buffType
			if buffType == 'cooldownABILITY' or buffType == 'cooldownITEM' then thisBuffType = 'cooldown' end

			local details

			--if unitName == nil then
				details = _internal.GetAnalyzerEntry(target, buffType, buffId)
			--else
			--	details = _internal.GetAnalyzerEntry(unitType, buffType, buffId)
			--end
			
			local newTrigger = {
				active = false,
				sType = thisBuffType,
				sId = buffId,
				showIfActive = false,
				stackTrigger = "na",
				stackCounter = 0
			}
			
			if unitType ~= nil then
				newTrigger.unitTypeKey = "addonType" .. unitType
				newTrigger.unitName = dropElement:GetValue("buffUnitName")
			else
				newTrigger.unitType = target
			end
			
			if thisBuffType == 'cooldown' then 
				newTrigger.cdType = EnKai.strings.right(buffType, "cooldown")
				newTrigger.showIfActive = false
			end

			local replaceTrigger
			
			local function _fctUpdate()
			
				local cacheKey = _internal.getCacheKey (newTrigger)
			
				nkRBCache[cacheKey] = {
					name = details.name,
					ability = details.ability,
					duration = details.duration,
					icon = details.icon,
					description = details.description,
					caster = details.caster,
					stack = details.stack
				}
				
				tabPane:UpdateTargetSelect(false)
				tabPane:rebuildButtons()
				tabPane:updateButtons()
			end
			
			local function _fctReplace()
			
				rbSet.trigger[replaceTrigger] = newTrigger
				rbSet.trigger[replaceTrigger].active = true
				_fctUpdate()
			
			end
			
			local function _fctAdd()
				local triggerId = EnKai.tools.uuid()
				rbSet.trigger[triggerId] = newTrigger
				rbSet.trigger[triggerId].active = true
				
				local iconData = EnKai.tools.table.copy(nkRBConfig.iconDefaults)
				iconData.textureType = "Rift"
				iconData.texturePath = details.icon
				iconData.label = details.name
				iconData.uiId = EnKai.tools.uuid()
				
				rbSet.icons[triggerId] = iconData
				
				_fctUpdate()
			end
			
			for idx = 1, #buttons, 1 do
				if buttons[idx]:GetId() ~= nil then
					if x >= buttons[idx]:GetLeft() and x <= buttons[idx]:GetLeft() + buttons[idx]:GetWidth() and y >= buttons[idx]:GetTop() and y <= buttons[idx]:GetTop() + buttons[idx]:GetHeight() then
						replaceTrigger = buttons[idx]:GetId()
						--print (replaceTrigger)
						EnKai.ui.confirmDialog (privateVars.langTexts.replaceTrigger, _fctReplace, _fctAdd)
						return
					end
				else
					break
				end
			end

			_fctAdd()
			
		end
		
	end
	
	function tabPane:UpdateSetSelect(force, updateButtons)
	
		if not force and not isBuilt then return end
		
		local selection = {}
			
		local set, default
		if setTypeSelect:GetSelectedValue() == 'mainSet' then
			set = nkRBSetMain
			default = nkRBConfig.activeSet
		else
			set = nkRBSetSub
			default = data.activeSubSet
		end
	
		for idx = 1, #set, 1 do
			table.insert (selection, { label = set[idx].name, value = idx })
		end
		
		if default == nil then default = selection[1].value end
		
		setSelect:SetSelection(selection)
		setSelect:SetSelectedValue(default, false)

		if updateButtons == false then return end
		
		
		
		EnKai.tools.perf.addToQueue(tabPane.rebuildButtons)
		EnKai.tools.perf.addToQueue(tabPane.updateButtons)

	end
	
	function tabPane:EditIcon(thisIcon)
	
		local setType, activeSet, triggerId = thisIcon:GetValue('setType'), thisIcon:GetValue('activeSet'), thisIcon:GetValue('triggerId')
		
		if currentIconEdit == triggerId then return end
		
		setTypeSelect:SetSelectedValue(setType)
		tabPane:UpdateSetSelect(true, false)
		setSelect:SetSelectedValue(activeSet)
		tabPane:UpdateTargetSelect(false)
		
		local rbSet
		
		if setTypeSelect:GetSelectedValue() == 'mainSet' then
			rbSet = nkRBSetMain[setSelect:GetSelectedValue()]
		else
			rbSet = nkRBSetSub[setSelect:GetSelectedValue()]
		end
		
		local trigger = rbSet.trigger[triggerId]
		local selection = targetSelect:GetValue('selection')
		
		for idx = 1, #selection, 1 do
			if selection[idx].value == trigger.unitType or selection[idx].value == trigger.unitTypeKey then
				targetSelect:SetSelectedValue(selection[idx].value, false)
				break
			end
		end
		
		tabPane:rebuildButtons()
		tabPane:updateButtons()
		
		EnKai.tools.perf.addToQueue(function()
			tabPane:SetIconEdit(triggerId)
		end) -- need to do this via queue as otherwise the queued build might not have happend yet
	
	end
	
	return tabPane
	
end
