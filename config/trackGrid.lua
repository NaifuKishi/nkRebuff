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

local function _addItem (itemType, itemId)

	-- local details = Inspect.Item.Detail(itemId)
	-- if details == nil then return end
	
	-- local list
	
	-- if itemType == 'mounts' and details.category ~= 'misc mount' then
		-- return
	-- elseif itemType == 'pets' and details.category ~= 'misc pet' then
		-- return
	-- end

	-- if EnKai.tools.table.isMember (nkZooSettings[itemType], itemId) then return end
	
	-- table.insert(nkZooSettings[itemType], itemId)
	
	
end


function _ui.ConfigTabTrackGrid (parent)

	local name = parent:GetName().. '.trackGrid'

	local tabPane = UI.CreateFrame ("Frame", name, parent)
	local scrollPane, content, setTypeSelect, iconEdit, targetSelect, setSelect
	
	local isBuilt = false
	
	local buttonCount = 40
	local buttons = {}
	
	function tabPane:rebuildButtons()
	
		local count = 0
		
		local dataSet
		
		if setTypeSelect:GetSelectedValue() == 'main' then
			dataSet = nkRBData[setSelect:GetSelectedValue()][targetSelect:GetSelectedValue()]
		else
			dataSet = nkRBSubData[setSelect:GetSelectedValue()][targetSelect:GetSelectedValue()]
		end
		
		for buffType, typeDetails in pairs(dataSet) do
			for k, v in pairs(typeDetails) do
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
					local unitType, contentType, contentKey = thisButton:GetContent()
					tabPane:SetIconEdit(unitType, contentType, contentKey)
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
	end
	
	function tabPane:updateButtons()
	
		local dataSet
		
		if setTypeSelect:GetSelectedValue() == 'main' then
			dataSet = nkRBData[setSelect:GetSelectedValue()][targetSelect:GetSelectedValue()]
		else
			dataSet = nkRBSubData[setSelect:GetSelectedValue()][targetSelect:GetSelectedValue()]
		end
		
		--print ('updateButtons')
		
		local count = 1
		for buffType, typeDetails in pairs(dataSet) do
			for key, v in pairs(typeDetails) do
				--print (buffType, key)
				
				buttons[count]:SetType(buffType)
				buttons[count]:SetTimer(v.duration)
				buttons[count]:SetStack(v.stack)
				buttons[count]:SetContent(targetSelect:GetSelectedValue(), buffType, key)
				buttons[count]:SetTexture("Rift", v.icon)

				EnKai.ui.attachGenericTooltip (buttons[count], v.name, v.description)
				
				count = count + 1
			end
		end
		
		if count <= #buttons then
			for idx = count, #buttons, 1 do
				buttons[idx]:SetContent(nil, nil, nil)
				buttons[idx]:ClearTexture()
				buttons[idx]:SetTimer(nil)
				buttons[idx]:SetStack(nil)
				buttons[idx]:SetType(nil)
				buttons[idx]:SetTintColor(0, 0, 0, 0)
				buttons[idx]:SetBackgroundColor(0.153, 0.314, 0.490, 1)

				EnKai.ui.attachAbilityTooltip (buttons[idx], nil)
			end
		end

	end
	
	function tabPane:build ()
	
		setTypeSelect = EnKai.uiCreateFrame("nkRadioButton", name .. '.setTypeSelect', tabPane)
		setTypeSelect:SetSelection(privateVars.langTexts.setTypeSelectList)
		setTypeSelect:SetSelectedValue('main')
		setTypeSelect:SetText(privateVars.langTexts.setTypeSelect)
		setTypeSelect:SetLabelWidth(100)
		setTypeSelect:SetWidth(300)
		setTypeSelect:SetLayer(9)
		setTypeSelect:SetPoint("TOPLEFT", tabPane, "TOPLEFT", 0, 0)
		
		Command.Event.Attach(EnKai.events[setTypeSelect:GetName()].RadiobuttonChanged, function()
			
			local selection = {}
			
			local set
			if setTypeSelect:GetSelectedValue() == 'main' then
				set = nkRBSets
			else
				set = nkRBSubSets
			end
		
			for idx = 1, #set, 1 do
				table.insert (selection, { label = set[idx].name, value = idx })
			end
			
			setSelect:SetSelection(selection)
			setSelect:SetSelectedValue(selection[1].value, false)
			
			tabPane:rebuildButtons()
			tabPane:updateButtons()
			
		end, setTypeSelect:GetName()..".RadiobuttonChanged")
		
		local selection = {}
		
		for idx = 1, #nkRBSets, 1 do
			table.insert (selection, { label = nkRBSets[idx].name, value = idx })
		end
		
		setSelect = EnKai.uiCreateFrame("nkComboBox", name .. '.setSelect', tabPane)
		setSelect:SetSelection(selection)
		setSelect:SetSelectedValue(nkRBConfig.activeSet, false)
		setSelect:SetText(privateVars.langTexts.setSelect)
		setSelect:SetLabelWidth(100)
		setSelect:SetWidth(300)
		setSelect:SetLayer(8)
		setSelect:SetPoint("TOPLEFT", setTypeSelect, "BOTTOMLEFT", 0, 5)
		
		Command.Event.Attach(EnKai.events[setSelect:GetName()].ComboChanged, function()
			tabPane:rebuildButtons()
			tabPane:updateButtons()
		end, setSelect:GetName()..".ComboChanged")
		
		targetSelect = EnKai.uiCreateFrame("nkComboBox", name .. '.targetSelect', tabPane)
		targetSelect:SetSelection(privateVars.langTexts.targetSelectList)
		targetSelect:SetSelectedValue('player')
		targetSelect:SetText(privateVars.langTexts.targetSelect)
		targetSelect:SetLabelWidth(100)
		targetSelect:SetWidth(300)
		targetSelect:SetLayer(7)
		targetSelect:SetPoint("TOPLEFT", setSelect, "BOTTOMLEFT", 0, 5)
		
		Command.Event.Attach(EnKai.events[targetSelect:GetName()].ComboChanged, function()
			tabPane:rebuildButtons()
			tabPane:updateButtons()
		end, targetSelect:GetName()..".ComboChanged")
	
		scrollPane = EnKai.uiCreateFrame("nkScrollPane", name .. '.scrollPane', tabPane)
		scrollPane:SetPoint("TOPLEFT", targetSelect, "BOTTOMLEFT", 0, 10)
		scrollPane:SetWidth(515)
		scrollPane:SetHeight(400)
		scrollPane:SetColor({r = 0.153, g = 0.314, b = 0.490, a = 1})
		
		scrollPane:SetColorInner({r = 0, g = 0, b = 0, a = 1})
		scrollPane:SetColorHighlight({r = 0.153, g = 0.314, b = 0.490, a = 1})
		scrollPane:SetLayer(1)	
		
		scrollPane:EventAttach(Event.UI.Input.Mouse.Left.Up, function (self)
			--_checkDrop()
		end, scrollPane:GetName() .. ".UI.Input.Mouse.Left.Up")
			
		content = UI.CreateFrame("Frame", name .. '.content', scrollPane)
		content:SetWidth(scrollPane:GetWidth())
		
		iconEdit = _ui.iconEdit (tabPane)
		iconEdit:SetPoint("TOPRIGHT", tabPane, "TOPRIGHT", 0, 0)
		iconEdit:SetVisible(false)
	
		tabPane:rebuildButtons()
		tabPane:updateButtons()
		isBuilt = true
	end

	function tabPane:SetIconEdit(unitType, contentType, key)
	
		--print (unitType, contentType, key)
		iconEdit:SetSet(setSelect:GetSelectedValue())
		iconEdit:SetSetType(setTypeSelect:GetSelectedValue())
		iconEdit:SetUnitType(unitType, contentType)
		iconEdit:SetBuffType(contentType)
		iconEdit:SetKey(key)
		
		local storedIcons, storedData 
		if setTypeSelect:GetSelectedValue() == 'main' then
			storedIcons = nkRBIcons[setSelect:GetSelectedValue()][unitType][contentType][key]
			storedData = nkRBData[setSelect:GetSelectedValue()][unitType][contentType][key]
		else
			storedIcons = nkRBSubIcons[setSelect:GetSelectedValue()][unitType][contentType][key]
			storedData = nkRBSubData[setSelect:GetSelectedValue()][unitType][contentType][key]
		end
		
		if storedIcons == nil then
			
			local iconData = EnKai.tools.table.copy (nkRBConfig.iconDefaults)
			
			iconData.texturePath = storedData.icon
			iconData.label = storedData.name
			iconEdit:RemoveIcon()
			iconEdit:SetConfig(iconData)
		else			
			-- evtl nur machen wenn auch aktiviert

			if uiElements.icons[unitType][contentType][key] == nil then
				uiElements.icons[unitType][contentType][key] = _internal.createIcon (unitType, contentType, key, storedIcons)
				uiElements.icons[unitType][contentType][key]:SetVisible(true)
			end
			
			iconEdit:SetIcon()
			iconEdit:SetConfig(storedIcons)
		end
			
		iconEdit:SetVisible(true)
	end
	
	function tabPane:GetSetSelect() return setSelect end
	
	function tabPane:CheckDrop(dropElement)
		
		local x, y = dropElement:GetLeft(), dropElement:GetTop()
		if x >= scrollPane:GetLeft() and x <= scrollPane:GetLeft() + scrollPane:GetWidth() - dropElement:GetWidth() and y >= scrollPane:GetTop() and y <= scrollPane:GetTop() + scrollPane:GetHeight() - dropElement:GetHeight() then
			local target, buffType, key = dropElement:GetContent()
			
			--print (target, buffType, key)
			
			local dataSet, thisSet, iconSet
			if setTypeSelect:GetSelectedValue() == 'main' then
				dataSet = nkRBData[setSelect:GetSelectedValue()]
				thisSet = nkRBSets[setSelect:GetSelectedValue()]
				iconSet = nkRBIcons[setSelect:GetSelectedValue()]
			else
				dataSet = nkRBSubData[setSelect:GetSelectedValue()]
				thisSet = nkRBSubSets[setSelect:GetSelectedValue()]
				iconSet = nkRBSubIcons[setSelect:GetSelectedValue()]
			end
			
			local thisBuffType = buffType
			if buffType == 'cooldownABILITY' or buffType == 'cooldownITEM' then thisBuffType = 'cooldown' end
			
			if dataSet[targetSelect:GetSelectedValue()][thisBuffType][key] ~= nil then return end
			
			local details = _internal.GetAnalyzerEntry(target, buffType, key)
			
			dataSet[target][buffType][key] = {
				name = details.name,
				hidden = false,
				ability = details.ability,
				duration = details.duration,
				icon = details.icon,
				description = details.description,
				caster = details.caster
			}

			thisSet[target][buffType][key] = { active = false }
			
			local iconData = EnKai.tools.table.copy(nkRBConfig.iconDefaults)
			iconData.textureType = "Rift"
			iconData.texturePath = details.icon
			iconData.label = details.name
			iconSet[target][buffType][key] = iconData
			
			tabPane:rebuildButtons()
			tabPane:updateButtons()
			
		end
		
	end
	
	return tabPane
	
end
