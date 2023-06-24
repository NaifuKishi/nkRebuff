local addonInfo, privateVars = ...

---------- init namespace ---------

if not nkRebuff then nkRebuff = {} end

privateVars.data		= {}
privateVars.internal	= {}
privateVars.uiElements	= {}
privateVars.events		= {}
privateVars.ui			= {}
privateVars.oFuncs		= {}

local data			= privateVars.data
local uiElements	= privateVars.uiElements
local _internal		= privateVars.internal
local _events		= privateVars.events
local _ui			= privateVars.ui
local oFuncs		= privateVars.oFuncs

oFuncs.InspectAddonCurrent = Inspect.Addon.Current
oFuncs.InspectAbilityNewDetail = Inspect.Ability.New.Detail
oFuncs.InspectMouse = Inspect.Mouse
oFuncs.InspectSystemSecure = Inspect.System.Secure
oFuncs.InspectRoleList = Inspect.Role.List
oFuncs.InspectTimeFrame = Inspect.Time.Frame
oFuncs.InspectTimeReal = Inspect.Time.Real
oFuncs.InspectItemDetail = Inspect.Item.Detail
oFuncs.InspectUnitDetail = Inspect.Unit.Detail

---------- init local variables ---------

---------- init variables ---------

data.isSecure = oFuncs.InspectSystemSecure()
data.activeSubSet = nil
data.trackedUnits = {}
data.configOpen = false

uiElements.icons = {}

---------- init ui context ---------

uiElements.context = UI.CreateContext("nkRebuff")

uiElements.configContext = UI.CreateContext ("nkRebuffConfig")
uiElements.configContext:SetStrata ('dialog')

uiElements.secureContext = UI.CreateContext("nkRebuffSecure")
uiElements.secureContext:SetSecureMode('restricted')

---------- local function block ---------

local function _fctCheckSecureEnter ()
	
	-- nkRebuff.logDebug ("secure enter")

	if EnKai.unit.getUnitIDByType('player.pet') ~= nil then
		local tmpTime = oFuncs.InspectTimeReal()
		if privateVars.lastPetCheck == nil or EnKai.tools.math.round((tmpTime - privateVars.lastPetCheck), 1) > 5 then
			privateVars.lastPetCheck = tmpTime
		end
	end
	
	data.overrideCombatCheck = true
	
	_internal.CheckMissingBuffs('player', '_fctCheckSecureEnter')
	_internal.CheckMissingBuffs('player.pet', '_fctCheckSecureEnter')
	_internal.CheckMissingBuffs('player.target', '_fctCheckSecureEnter')
	_internal.CheckCooldownsReady()

	data.overrideCombatCheck = false
	
	_internal.setReBuffMacro()
	
	data.isSecure = true

end

local function _fctCheckSecureLeave ()

	-- nkRebuff.logDebug ("secure leave")

	if nkRBConfig.combatOnly == true then _internal.hideAllIcons() end
	_internal.setReBuffMacro()
	data.isSecure = false

end

local function _fctShowConfig()

	if uiElements.configUI == nil then 
		uiElements.configUI = _ui.Config()
	elseif uiElements.configUI:GetVisible() == true then
		uiElements.configUI:SetVisible(false)
	else
		uiElements.configUI:SetVisible(true) 
	end

end

local function _fctSetBuffButtonMacro(ignoreFirst)

	if uiElements.buffButton == nil then return end

	if nkRBConfig.buffButton == '0' or nkRBConfig.buffButton == 'all' then return end
	if oFuncs.InspectSystemSecure() == true then return end
	
	local firstIgnored = false
	
	local hasPet = false
	if oFuncs.InspectUnitDetail('player.pet') ~= nil then hasPet = true end
	
	for triggerId, triggerDetails in pairs(nkRBSetMain[nkRBConfig.activeSet].trigger) do
		if triggerDetails.active and triggerDetails.sType ~= 'cooldown' then
			if triggerDetails.unitType == 'player' or (hasPet and triggerDetails.unitType == 'player.pet') then
			
				if EnKai.BuffManager.isBuffActive(triggerDetails.unitType, triggerDetails.sId) == false then
				
					local cacheKey = _internal.getCacheKey (triggerDetails)
					local cacheData = nkRBCache[cacheKey]
					
					if cacheData ~= nil and (cacheData.duration == nil or cacheData.duration > 120) then
					
						if ignoreFirst ~= true or firstIgnored == true then
							uiElements.buffButton:SetMacro("cast " .. cacheData.name .. '\nnkRB int001')
							uiElements.buffButton:SetValue('ability', cacheData.name)
							uiElements.buffButton:SetActiveState(false)
							uiElements.buffButton:SetVisible(true)
							return
						elseif ignoreFirst == true then
							firstIgnored = true
						end
					end
					
				end
			end
		end
	end
	
	uiElements.buffButton:SetMacro(nil)
	uiElements.buffButton:SetActiveState(true)
	
	if nkRBConfig.buffButton == 'rebuff' then uiElements.buffButton:SetVisible(false) end

end

local function _fctCommandHandler(commandline)

	if string.find(commandline, 'int001') ~= nil then
		_fctSetBuffButtonMacro(true)
	elseif string.find(commandline, 'mainset=') ~= nil then
		local pos = string.find(commandline, 'mainset=')
		local setno = tonumber(EnKai.strings.right(commandline, 'mainset='))
		
		if setno < 1 or setno > #nkRBSetMain then
			Command.Console.Display("general", true, string.format(privateVars.langTexts.various.commandSetRefuse, #nkRBSetMain), true)
		else
			_internal.activateSet ("mainSet", setno)
		end
	elseif string.find(commandline, 'subset=') ~= nil then
		local pos = string.find(commandline, 'subset=')
		local setno = tonumber(EnKai.strings.right(commandline, 'subset='))
		
		if setno < 1 or setno > #nkRBSetSub then
			Command.Console.Display("general", true, string.format(privateVars.langTexts.various.commandSetRefuse, #nkRBSetSub), true)
		else
			_internal.activateSet ("subSet", setno)
		end
	elseif string.find(commandline, "analyze") ~= nil then
		_internal.initAnalyzer(not _internal.analyzerActive())
		
		if uiElements.configUI ~= nil then
			uiElements.configUI:InitAnalyze(_internal.analyzerActive())
		end
		
	else
		_fctShowConfig()
	end
	
end

local function _fctMain(_, addon)

	if addon == addonInfo.identifier then
	
		if nkRBSets ~= nil then return end -- need to go out here due to migration of settings outstanding
	
		EnKai.unit.init()
		EnKai.cdManager.init()
		EnKai.cdManager.setGCD(nkRBConfig.gcd)
		EnKai.BuffManager.init()
		
		Command.Event.Attach(EnKai.events["EnKai.Unit"].Available, _internal.UnitAvailable, "nkRebuff.EnKai.Unit.Available")
	
		table.insert(Command.Slash.Register("nkRebuff"), {_fctCommandHandler, "nkRebuff", "config"})
		table.insert(Command.Slash.Register("nkr"), {_fctCommandHandler, "nkRebuff", "config"})
		table.insert(Command.Slash.Register("nkrb"), {_fctCommandHandler, "nkRebuff", "config"})
		
		local items = {
			{ label = privateVars.langTexts.various.buttonMenuConfig, callBack = function () _fctShowConfig() end},
			{ seperator = true }
		}

		for idx = 1, #nkRBSetMain, 1 do
			table.insert (items, { label = nkRBSetMain[idx].name, callBack = function() _internal.activateSet ("mainSet", idx) end })
		end
		
		table.insert(items, { seperator = true })
		
		for idx = 1, #nkRBSetSub, 1 do
			table.insert (items, { label = nkRBSetSub[idx].name, callBack = function() _internal.activateSet ("subSet", idx) end })
		end
		
		if nkPanel ~= nil and nkRBConfig.nkPanel == true then
			uiElements.panel = _internal.nkPanelPlugin(items)
			nkPanel.api.registerPlugin('nkRebuff', uiElements.panel)
			uiElements.panel:SetTitle(nkRBSetMain[nkRBConfig.activeSet].name)
		end
		
		EnKai.manager.init('nkRebuff', items, nil)
		
		if nkRBConfig.buffButton ~= "0" then _internal.buildReBuff() end
		
		EnKai.version.init(addonInfo.toc.Identifier, addonInfo.toc.Version)
		
		Command.Event.Attach(Event.System.Secure.Leave, _fctCheckSecureLeave, "nkRebuff.System.Secure.Leave")
		Command.Event.Attach(Event.System.Secure.Enter, _fctCheckSecureEnter, "nkRebuff.System.Secure.Enter")
		Command.Event.Attach(Event.TEMPORARY.Role, _internal.RoleChange, "nkRebuff.Unit.Detail.Role")
					
	end
	
end

local function _fctMigrateSettings ()

	for idx = 1, #nkRBSets, 1 do
		local newSet = { name = nkRBSets[idx].name, role = nkRBSets[idx].role, trigger = {}, icons = {} }
		
		for setType, setDetails in pairs(nkRBSets[idx]) do
			if setType ~= 'name' and setType ~= 'role' then
				for id, details in pairs(nkRBSets[idx][setType]) do
					local newTrigger = { active = details.active, sType = 'buff', sId = id, stackTrigger = "na", stackCounter = 0 }
					
					if setType == 'buffsPet' then
						newTrigger.unitType = 'player.pet'
					elseif setType == 'buffsPlayer' then
						newTrigger.unitType = 'player'
					elseif setType == 'cooldownsPlayer' then
						newTrigger.unitType = 'player'
						newTrigger.cdType = 'ABILITY'
						newTrigger.sType = 'cooldown'
					else
						newTrigger.unitType = 'player.target'
						newTrigger.sType = 'debuff'
					end
					
					local newIcon
					
					if nkRBIcons[idx][setType][id] == nil then
						newIcon = EnKai.tools.table.copy(nkRBConfig.iconDefaults)
					else
						newIcon = EnKai.tools.table.copy(nkRBIcons[idx][setType][id])
					end
					
					newIcon.uiId = EnKai.tools.uuid()
					newTrigger.showIfActive = newIcon.showIfActive
					newIcon.showIfActive = nil
					
					local data = nkRBData[idx][setType][id]
					
					local newCacheEntry = {
						duration = data.duration,
						icon = data.icon,
						name = data.name,
						ability = data.ability,
					}
					
					if newIcon.texturePath == nil then newIcon.texturePath = newCacheEntry.icon end
					
					table.insert(newSet.trigger, newTrigger)
					table.insert(newSet.icons, newIcon)
					
					local thisId = newTrigger.unitType .. "-" .. newTrigger.sType .. "-" .. newTrigger.sId
					nkRBCache[thisId] = newCacheEntry
				end
			end
		end
		
		table.insert(nkRBSetMain, newSet)
	end
	
	nkRBSets = nil
	nkRBIcons = nil
	nkRBData = nil
	
	_fctMain(_, addonInfo.identifier)

end

local function _fctSettingsHandler(_, addon) 

	if addon ~= addonInfo.identifier then return end
	
	if nkRBSetMain == nil then
		nkRBSetMain = { { name = "default", role = 0, trigger = {}, icons = {} }}
		nkRBSetSub = { { name = "default", trigger = {}, icons = {} }}
		nkRBCache = {}
	end
	
	if nkRBConfig == nil then 
		nkRBConfig = {	buffButton = '0',
						buffButtonScale = 100,
						buffButtonXPos = 800,
						buffButtonYPos = 400,
						gcd = 1.5,
						showBarsDuringConfig = true,
						nkPanel = true,
						activeSet = 1,
						combatOnly = false,
						throttle = 1,
						locked = true,
						autoRoleSwitch = false,
						iconDefaults = {	shortLabels = false, 
											effect = 'gloss',
											useDefaults = true,
											warnDurationLessThan = 20,
											showLabel = true,
											showBorder = true,
											showTimer = true,
											showStack = false,
											labelColor = {1, 1, 1, 1},
											borderColor = {0, 0, 0, 1},
											timerColor = {1, 1, 1, 1},
											timerOutlineColor = {0, 0, 0, 1},
											stackColor = {1, 1, 1, 1},
											scale = 100,
											textureType = 'Rift',
											texturePath = nil,
											xpos = 400,
											ypos = 100
										}
					}
	end
	
	if nkRBConfig.gcd == nil then nkRBConfig.gcd = 1.5 end
	
	if nkRBSets ~= nil then
		EnKai.ui.messageDialog (string.format(privateVars.langTexts.msgMigrate, addonInfo.toc.Version), _fctMigrateSettings)
	end
	
end

local function _fctBuildBuffButtonBar()

	if uiElements.buffButtonBar ~= nil then return end

	uiElements.buffButtonBar = EnKai.uiCreateFrame('nkFrame', 'nkRB.buffButtonBar', uiElements.secureContext)
	uiElements.buffButtonBar:SetSecureMode('restricted')
	uiElements.buffButtonBar:SetVisible(false)
	
	local subButtons = {}
	local subButtonIDs = {}
	local object, to = uiElements.buffButtonBar, "TOPLEFT"
	
	local width, height = 0, 0 
	
	local targets = {'player'}
	if oFuncs.InspectUnitDetail('player.pet') ~= nil then table.insert(targets, 'player.pet') end
	
	for triggerId, triggerDetails in pairs(nkRBSetMain[nkRBConfig.activeSet].trigger) do
		if triggerDetails.active and triggerDetails.sType ~= 'cooldown' then
			if triggerDetails.unitType == 'player' or triggerDetails.unitType == 'player.pet' then
				
				local cacheKey = _internal.getCacheKey (triggerDetails)
				local cacheData = nkRBCache[cacheKey]
				
				if cacheData ~= nil then
					local button = EnKai.uiCreateFrame("nkActionButton", "nkRB.buffButton." .. (#subButtons + 1), uiElements.buffButtonBar)
					button:SetScale(nkRBConfig.buffButtonScale / 100)
					button:SetPoint("TOPLEFT", object, to)
					button:SetMacro("cast " .. cacheData.name)
					button:SetValue('ability', cacheData.name)
					button:SetTexture("Rift", cacheData.icon)
						
					if #subButtons == 0 then
						Command.Event.Attach(EnKai.events["nkRB.buffButton.1"].Moved, function (_, x, y)
							nkRBConfig.buffButtonXPos = x
							nkRBConfig.buffButtonYPos = y
						end, "nkRB.buffButton.1.Moved")
					end
						
					width = width + button:GetWidth()
					height = button:GetHeight()
					table.insert(subButtons, button)

					subButtonIDs[triggerDetails.sId] = #subButtons
					object = button
					to = "TOPRIGHT"
				end
				
			end
		end
	end
	
	if #subButtons == 0 then
		local button = EnKai.uiCreateFrame("nkActionButton", "nkRB.buffButton.1" , uiElements.buffButtonBar)
		button:SetScale(nkRBConfig.buffButtonScale/100)
		button:SetPoint("TOPLEFT", object, to)
		button:SetTexture("Rift", "Data/\\UI\\item_icons\\vanity_125_gloves_a.dds")
		
		if #subButtons == 0 then
			Command.Event.Attach(EnKai.events["nkRB.buffButton.1"].Moved, function (_, x, y)
				nkRBConfig.buffButtonXPos = x
				nkRBConfig.buffButtonYPos = y
			end, "nkRB.buffButton.1.Moved")
		end
		
		width = width + button:GetWidth()
		height = button:GetHeight()
		
		table.insert(subButtons, button)
	end
	
	uiElements.buffButtonBar.subButtons = subButtons
	uiElements.buffButtonBar.subButtonIDs = subButtonIDs
	
	uiElements.buffButtonBar:SetWidth(width)
	uiElements.buffButtonBar:SetHeight(height)
	
	if nkRBConfig.buffButtonXPos + uiElements.buffButtonBar:GetWidth() > UIParent:GetWidth() then nkRBConfig.buffButtonXPos = UIParent:GetWidth() - uiElements.buffButtonBar:GetWidth() end
	if nkRBConfig.buffButtonXPos < 0 then nkRBConfig.buffButtonXPos = 0 end
	
	if nkRBConfig.buffButtonYPos + uiElements.buffButtonBar:GetHeight() > UIParent:GetHeight() then nkRBConfig.buffButtonYPos = UIParent:GetHeight() - uiElements.buffButtonBar:GetHeight() end
	if nkRBConfig.buffButtonYPos < 0 then nkRBConfig.buffButtonYPos = 0 end
	
	uiElements.buffButtonBar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", nkRBConfig.buffButtonXPos, nkRBConfig.buffButtonYPos)
	
	uiElements.buffButtonBar:SetVisible(true)

end

local function _fctUpdateBuffButtonBar ()

	for idx = 1, #uiElements.buffButtonBar.subButtons, 1 do
		uiElements.buffButtonBar.subButtons[idx]:SetAlpha(0.3)
		uiElements.buffButtonBar.subButtons[idx]:SetVisible(true)
	end
	
	uiElements.buffButtonBar.subButtonIDs = {}	
	local subButtonIDs = {}

	local object, to = uiElements.buffButtonBar, "TOPLEFT"
	
	local width, height, counter = 0, 0, 1
	
	local hasPet = false
	if oFuncs.InspectUnitDetail('player.pet') ~= nil then hasPet = true end
	
	for triggerId, triggerDetails in pairs(nkRBSetMain[nkRBConfig.activeSet].trigger) do
		if triggerDetails.active and triggerDetails.sType ~= 'cooldown' then
			if triggerDetails.unitType == 'player' or (hasPet and triggerDetails.unitType == 'player.pet') then
			
				local cacheKey = _internal.getCacheKey (triggerDetails)
				local cacheData = nkRBCache[cacheKey]
				
				if cacheData ~= nil and (cacheData.duration == nil or cacheData.duration > 120) then
					local button = nil
					
					if uiElements.buffButtonBar.subButtons[counter] == nil then
						button = EnKai.uiCreateFrame("nkActionButton", "nkRB.buffButton." .. counter, uiElements.buffButtonBar)
						button:SetPoint("TOPLEFT", object, to)
					else
						button = uiElements.buffButtonBar.subButtons[counter]
					end
					
					button:SetScale(nkRBConfig.buffButtonScale/100)
					button:SetMacro("cast " .. cacheData.name)
					button:SetValue('ability', cacheData.name)
					button:SetTexture("Rift", cacheData.icon)
					button:SetVisible(true)
					
					width = width + button:GetWidth()
					height = button:GetHeight()
					
					if uiElements.buffButtonBar.subButtons[counter] == nil then
						table.insert(uiElements.buffButtonBar.subButtons, button)
						subButtonIDs[triggerDetails.sId] = #uiElements.buffButtonBar.subButtons
					else
						subButtonIDs[triggerDetails.sId] = counter
					end
					
					object = button
					to = "TOPRIGHT"
					counter = counter + 1
				end
			end
		end
	end

	if counter < #uiElements.buffButtonBar.subButtons then
		for idx = counter, #uiElements.buffButtonBar.subButtons, 1 do
			if counter > 1 or idx > 1 then
				uiElements.buffButtonBar.subButtons[idx]:SetVisible(false)
			end
		end
	end
	
	if counter == 1 then
		uiElements.buffButtonBar.subButtons[1]:SetTexture("Rift", "Data/\\UI\\item_icons\\vanity_125_gloves_a.dds")
	end
	
	uiElements.buffButtonBar.subButtonIDs = subButtonIDs

end

local function _fctUpdateReBuff()

	if nkRBConfig.buffButton == '0' then return end
	
	if nkRBConfig.buffButton == 'bar' then
		if uiElements.buffButtonBar == nil then 
			_fctBuildBuffButtonBar()
		else
			_fctUpdateBuffButtonBar()
		end
	else
		_fctSetBuffButtonMacro()
	end	

end

local function _fctSetBuffButtonBarMacro()

	if uiElements.buffButtonBar == nil then return end

	if nkRBConfig.buffButton ~= 'bar' then return end
	
	for idx = 1, #uiElements.buffButtonBar.subButtons, 1 do
		uiElements.buffButtonBar.subButtons[idx]:SetAlpha(0.3)
	end
	
	local hasPet = false
	if oFuncs.InspectUnitDetail('player.pet') ~= nil then hasPet = true end
	
	for triggerId, triggerDetails in pairs(nkRBSetMain[nkRBConfig.activeSet].trigger) do
		
		if triggerDetails.active and triggerDetails.sType ~= 'cooldown' then
			if triggerDetails.unitType == 'player' or (hasPet and triggerDetails.unitType == 'player.pet') then
				local index = uiElements.buffButtonBar.subButtonIDs[triggerDetails.sId]
				
				if index ~= nil then
				
					if EnKai.BuffManager.isBuffActive(triggerDetails.unitType, triggerDetails.sId) == false then
					
						local cacheKey = _internal.getCacheKey (triggerDetails)
						local cacheData = nkRBCache[cacheKey]
						
						if cacheData ~= nil and (cacheData.duration == nil or cacheData.duration > 120) then
							uiElements.buffButtonBar.subButtons[index]:SetAlpha(1)
						end
					else
						uiElements.buffButtonBar.subButtons[index]:SetAlpha(0.3)
					end
				end
			end
		end
		
	end

end

local function _fctBuildBuffButton()
	
	if uiElements.buffButton ~= nil then return end
	
	uiElements.buffButton = EnKai.uiCreateFrame("nkActionButton", "nkRB_buffButton", uiElements.secureContext)			
	uiElements.buffButton:SetTexture("Rift", "Data/\\UI\\item_icons\\vanity_125_gloves_a.dds")
	uiElements.buffButton:SetScale(nkRBConfig.buffButtonScale/100)
	
	if nkRBConfig.buffButtonXPos + uiElements.buffButton:GetWidth() > UIParent:GetWidth() then nkRBConfig.buffButtonXPos = UIParent:GetWidth() - uiElements.buffButton:GetWidth() end
	if nkRBConfig.buffButtonXPos < 0 then nkRBConfig.buffButtonXPos = 0 end
	
	if nkRBConfig.buffButtonYPos + uiElements.buffButton:GetHeight() > UIParent:GetHeight() then nkRBConfig.buffButtonYPos = UIParent:GetHeight() - uiElements.buffButton:GetHeight() end
	if nkRBConfig.buffButtonYPos < 0 then nkRBConfig.buffButtonYPos = 0 end
	
	uiElements.buffButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", nkRBConfig.buffButtonXPos, nkRBConfig.buffButtonYPos)
	
	uiElements.buffButton:SetVisible(true)
			
	uiElements.buffButton:EventAttach(Event.UI.Input.Mouse.Cursor.In, function (self)
		--if uiElements.infoBlock == nil then uiElements.infoBlock = _ui.infoBlock() end
		
		-- uiElements.infoBlock:SetHeader(privateVars.langTexts.buffButtonHintHeader)
		-- uiElements.infoBlock:SetDescription(string.format(privateVars.langTexts.buffButtonHintDesc, uiElements.buffButton:GetValue('ability')))
		
		-- local width, height = uiElements.infoBlock:GetWidth(), uiElements.infoBlock:GetHeight() 
		-- uiElements.infoBlock:ClearAll()
		-- uiElements.infoBlock:SetWidth(width)
		-- uiElements.infoBlock:SetHeight(height)
		-- uiElements.infoBlock:SetPoint("BOTTOMRIGHT", uiElements.buffButton, "TOPRIGHT")
		-- uiElements.infoBlock:SetVisible(true)			
	end, "nkRB_buffButton" .. '.Mouse.Cursor.In')
	
	uiElements.buffButton:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function (self)
		--if uiElements.infoBlock ~= nil then uiElements.infoBlock:SetVisible(false) end
	end, "nkRB_buffButton" .. '.Mouse.Cursor.Out')
	
	Command.Event.Attach(EnKai.events.nkRB_buffButton.Moved, function (_, x, y)
	
		if oFuncs.InspectSystemSecure() == true then return end
	
		nkRBConfig.buffButtonXPos = x
		nkRBConfig.buffButtonYPos = y
		
		if nkRBConfig.buffButtonXPos + uiElements.buffButton:GetWidth() > UIParent:GetWidth() then nkRBConfig.buffButtonXPos = UIParent:GetWidth() - uiElements.buffButton:GetWidth() end
		if nkRBConfig.buffButtonXPos < 0 then nkRBConfig.buffButtonXPos = 0 end
		
		if nkRBConfig.buffButtonYPos + uiElements.buffButton:GetHeight() > UIParent:GetHeight() then nkRBConfig.buffButtonYPos = UIParent:GetHeight() - uiElements.buffButton:GetHeight() end
		if nkRBConfig.buffButtonYPos < 0 then nkRBConfig.buffButtonYPos = 0 end
		
		uiElements.buffButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", nkRBConfig.buffButtonXPos, nkRBConfig.buffButtonYPos)
	end, "nkRB_buffButton.Moved")
	
end

---------- addon internal function block ---------

function _internal.EventSubscriptions(setType, oldSet, newSet)

	local setDef = nkRBSetMain
	if setType == 'subSet' then setDef = nkRBSetSub end

	if oldSet ~= nil then
		for id, details in pairs(setDef[oldSet].trigger) do
		
			if details.unitType ~= nil then EnKai.tools.table.removeValue(data.trackedUnits, details.unitType) end
			if details.unitType ~= nil then EnKai.tools.table.removeValue(data.trackedUnits, details.unitTypeKey) end
		
			if details.sType == 'cooldown' then
				EnKai.cdManager.unsubscribe(details.cdType, sID)
			else
				EnKai.BuffManager.unsubscribe(details.sType, sID)
			end
		end
	end

	if newSet ~= nil and newSet ~= 0 then
	
		for id, details in pairs(setDef[newSet].trigger) do
		
			if details.sType == 'cooldown' then
				EnKai.cdManager.subscribe(details.cdType, details.sId)
			elseif details.unitTypeKey ~= nil then
				EnKai.tools.table.addValue (data.trackedUnits, details.unitTypeKey)
				EnKai.BuffManager.subscribe(details.sType, details.sId, EnKai.unit.getPlayerDetails().id, details.unitTypeKey, 0)
			else
				EnKai.tools.table.addValue (data.trackedUnits, details.unitType)
				EnKai.BuffManager.subscribe(details.sType, details.sId, EnKai.unit.getPlayerDetails().id, details.unitType, 0)
			end
		end
	end
	
end

function _internal.activateSet (setType, newSet)
	
	if EnKai.unit.getUnitIDByType('player') == nil then return end
	
	if setType == 'mainSet' and nkRBConfig.activeSet == newSet then return end
	if setType == 'subSet' and data.activeSubSet == newSet then return end
	
	local setDef, lastSet = nkRBSetMain, nkRBConfig.activeSet
	if string.upper(setType) == 'SUBSET' then setDef, lastSet = nkRBSetSub, data.activeSubSet end
	
	_internal.hideAllIcons()
	_internal.CheckMissingBuffs('player', '_internal.activateSet')
	_internal.CheckCooldownsReady()
	_internal.EventSubscriptions(setType, lastSet, newSet)
	
	local msg, name
	
	if setType == 'mainSet' then
		nkRBConfig.activeSet = newSet
		name = nkRBSetMain[newSet].name
		msg = privateVars.langTexts.various.activateMainSet
	else
		data.activeSubSet = newSet
		if newSet ~= nil then 
			name = nkRBSetSub[newSet].name 
		else
			name = privateVars.langTexts.noSubSet
		end
		msg = privateVars.langTexts.various.activateSubSet
	end
	
	if uiElements.configUI ~= nil and uiElements.configUI:GetVisible() == true then _internal.displayAllIcons(true) end

	if uiElements.panel ~= nil then
		uiElements.panel:SetTitle(nkRBSetMain[nkRBConfig.activeSet].name)
	end
	
	if setType == 'mainSet' then
		EnKai.events.addInsecure(function()
			_fctUpdateReBuff()
		end)
	end
	
	Command.Console.Display("general", true, string.format(msg, name), true)
	
end

function _internal.RoleChange (_, roleID)

	if nkRBConfig.autoRoleSwitch == true then
	
		for idx = 1, #nkRBSetMain, 1 do
			if nkRBSetMain[idx].role == roleID then
				_internal.activateSet ("mainSet", idx)
				return
			end
		end
	end
	
	if uiElements.configUI ~= nil then
		uiElements.configUI:InitAnalyze(false)
		_internal.initAnalyzer(false)
	end
	
	if uiElements.Analyzer ~= nil then
		uiElements.Analyzer:SetVisible(false)
		_internal.resetAnalyzer()
	end

end

function _internal.buildReBuff()

	if nkRBConfig.buffButton == '0' then return end
	
	if nkRBConfig.buffButton == 'bar' then
		if uiElements.buffButton ~= nil then uiElements.buffButton:SetVisible(false) end  
		
		if uiElements.buffButtonBar == nil then 
			_fctBuildBuffButtonBar()
		else
			_fctUpdateBuffButtonBar()
		end
	else
		if uiElements.buffButtonBar ~= nil then uiElements.buffButtonBar:SetVisible(false) end
		_fctBuildBuffButton()
	end	

end

function _internal.setReBuffMacro()

	if nkRBConfig.buffButton == '0' then return end
	
	if nkRBConfig.buffButton == 'bar' then
		_fctSetBuffButtonBarMacro()
	else
		_fctSetBuffButtonMacro()
	end	

end

function _internal.getCacheKey (trigger)

	local key
	if trigger.unitTypeKey ~= nil then
		key = trigger.unitTypeKey
	else
		key = trigger.unitType
	end
	
	key = key .. "-" .. trigger.sType .. "-" .. trigger.sId
	
	return key

end

function _internal.isTrigger(trigger, sType, sId, unitType)

	if trigger.sType ~= sType then return false end
	if trigger.sId ~= sId then return false end
	
	if trigger.unitTypeKey ~= "addonType" .. unitType and trigger.unitTypeKey ~= unitType and trigger.unitType ~= unitType then return false end
	
	return true
	
end

function _internal.getSetByType (setType, setId)

	if setType == 'mainSet' then return nkRBSetMain[setId] end
	return nkRBSetSub[setId]

end

function _internal.getSetList()

	local setList = { mainSet = nkRBSetMain[nkRBConfig.activeSet]}
	if data.activeSubSet ~= nil and data.activeSubSet ~= 0 then setList.subSet = nkRBSetSub[data.activeSubSet] end
	
	return setList

end

function _internal.getActiveSet(setType)

	local activeSet = nkRBConfig.activeSet
	if setType == 'subSet' then activeSet = data.activeSubSet end
	
	return activeSet

end

---------- startup events ---------

Command.Event.Attach(Event.Addon.Load.End, _fctMain, "nkRebuff.Addon.Load.End")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, _fctSettingsHandler, "nkRebuff.SavedVariables.Load.End")
