local addonInfo, privateVars = ...

---------- init namespace ---------

local uiElements	= privateVars.uiElements
local _internal		= privateVars.internal
local data			= privateVars.data
local oFuncs		= privateVars.oFuncs

---------- init local variables ---------

local _eventsInit = false

---------- init variables ---------

---------- local function block ---------

local function _fctIsValidUnit(unit)

	if string.find(unit, "addonType") ~= nil then
		local unitTypeList = EnKai.unit.getUnitTypes(unit)
		if EnKai.tools.table.isMember(unitTypeList, EnKai.strings.right(unit, "addonType")) then
			return true
		end
	elseif EnKai.tools.table.isMember(EnKai.unit.getUnitIDByType('player'), unit) then
		return true
	elseif EnKai.tools.table.isMember(EnKai.unit.getUnitIDByType('player.target'), unit) then
		return true
	elseif EnKai.tools.table.isMember(EnKai.unit.getUnitIDByType('player.pet'), unit) then
		return true
	else
		local unitTypeList = EnKai.unit.getUnitTypes(unit)
	
		for _, id in pairs (data.trackedUnits) do
			if EnKai.tools.table.isMember(unitTypeList, EnKai.strings.right(id, "addonType")) then
				return true
			end
		end
	end
	
	return false
	
end


local function _fctProcessBuffAdd(setType, activeSet, iconKey, trigger, iconDef, thisUnitType, buffDetails)

	local flag = _internal.CheckDisplay(trigger, buffDetails.stack, nil, nil, '_fctProcessBuffAdd')

	if _flag then
		local icon = _internal.displayOrCreateIcon (setType, activeSet, iconKey, trigger, iconDef, buffDetails.name, buffDetails.description)
		icon:SetTimer("")
		if buffDetails.stack ~= nil then icon:SetStack(buffDetails.stack) else icon:SetStack("") end
	else
		local thisIcon = uiElements.icons[iconDef.uiId]
	
		if thisIcon ~= nil then
			thisIcon:SetVisible(false)
		end
	end
	
	if thisUnitType == 'player' or thisUnitType == 'player.pet' then _internal.setReBuffMacro() end

end

local function _fctBuffAdd (_, unit, addon, buffs)

	if addon ~= oFuncs.InspectAddonCurrent() then return end
	if nkRBConfig.combatOnly == true and data.isSecure == false then return end
	
	if _fctIsValidUnit(unit) == false then return end
	
	local unitTypeList = EnKai.unit.getUnitTypes(unit)
	local setList = _internal.getSetList()
	
	for buffId, buffDetails in pairs(buffs) do

		for idx = 1, #unitTypeList, 1 do
			local thisUnitType = unitTypeList[idx]
			
			for setType, thisSet in pairs(setList) do
			
				for key, triggerDetails in pairs(thisSet.trigger) do
					if _internal.isTrigger(triggerDetails, buffDetails.bType, buffDetails.typeKey, thisUnitType) then
						_fctProcessBuffAdd(setType, _internal.getActiveSet(setType), key, triggerDetails, thisSet.icons[key], thisUnitType, buffDetails)
					end
				end
			end
		end
	end

end

local function _fctProcessBuffRemove(setType, activeSet, triggerKey, trigger, iconDef, thisUnitType, buffDetails)

	if trigger.active then
	
		if _internal.CheckDisplay(trigger, buffDetails.stack, nil, nil, '_fctProcessBuffRemove') then
		
			local icon = _internal.displayOrCreateIcon (setType, activeSet, triggerKey, trigger, iconDef, buffDetails.name, buffDetails.description)
			icon:SetTimer("")
			if buffDetails.stack ~= nil then icon:SetStack(buffDetails.stack) else icon:SetStack("") end
			if thisUnitType == 'player' or thisUnitType == 'player.pet' then _internal.setReBuffMacro() end
			
		else
			local thisIcon = uiElements.icons[iconDef.uiId]
		
			if thisIcon ~= nil then
				thisIcon:SetInfoBlock(buffDetails.name, buffDetails.description) 
				thisIcon:SetVisible(false) 
			end
			
		end
	end

end

local function _fctBuffRemove(_, unit, addon, buffs)

	if addon ~= oFuncs.InspectAddonCurrent() then return end
	if nkRBConfig.combatOnly == true and data.isSecure == false then return end

	if _fctIsValidUnit(unit) == false then return end
	
	local unitTypeList = EnKai.unit.getUnitTypes(unit)
	
	local setList = _internal.getSetList()
	
	for buffId, buffDetails in pairs(buffs) do

		for idx = 1, #unitTypeList, 1 do
			local thisUnitType = unitTypeList[idx]
			
			for setType, thisSet in pairs(setList) do
			
				for key, triggerDetails in pairs(thisSet.trigger) do
					
					if _internal.isTrigger(triggerDetails, buffDetails.bType, buffDetails.typeKey, thisUnitType) then
						_fctProcessBuffRemove(setType, _internal.getActiveSet(setType), key, triggerDetails, thisSet.icons[key], thisUnitType, buffDetails)
					end
				end
			end
		end
	end

end

local function _fctProcessBuffChange(setType, activeSet, triggerKey, trigger, iconDef, buffDetails)

	if buffDetails.remaining < 0 then buffDetails.remaining = 0 end -- temp fix until I find time to check EnKai buffhandler causing this

	local flag = _internal.CheckDisplay(trigger, buffDetails.stack, buffDetails.remaining, _internal.GetWarnDuration(iconDef), '_fctProcessBuffChange')
	
	if flag then
		local icon = _internal.displayOrCreateIcon(setType, activeSet, triggerKey, trigger, iconDef, buffDetails.bType, buffDetails.typeKey)
		
		if buffDetails.remaining >= 1 then
			icon:SetTimer(tostring(EnKai.tools.math.round(buffDetails.remaining, 0)))
		else
			icon:SetTimer(string.format("%0.1f", buffDetails.remaining))
		end
			
		if iconDef.showStack == true then icon:SetStack(buffDetails.stack) end
	else
		local thisIcon = uiElements.icons[iconDef.uiId]
	
		if thisIcon ~= nil and not data.configOpen then
			thisIcon:SetVisible(false)
		end
	end

end

local function _fctBuffChange (_, unit, addon, buffs)

	if addon ~= oFuncs.InspectAddonCurrent() then return end
	if nkRBConfig.combatOnly == true and data.isSecure == false then return end
	
	if _fctIsValidUnit(unit) == false then return end
	
	local unitTypeList = EnKai.unit.getUnitTypes(unit)
	local setList = _internal.getSetList()
	
	for buffId, buffDetails in pairs(buffs) do
	
		for idx = 1, #unitTypeList, 1 do
			local thisUnitType = unitTypeList[idx]

			for setType, thisSet in pairs(setList) do
				for key, triggerDetails in pairs(thisSet.trigger) do
				
					if _internal.isTrigger(triggerDetails, buffDetails.bType, buffDetails.typeKey, thisUnitType) then
						_fctProcessBuffChange(setType, _internal.getActiveSet(setType), key, triggerDetails, thisSet.icons[key], buffDetails)
					end
				end
			end
		end
	end
	
end

local function _fctCooldownBegin (_, addon, cooldowns)

	if addon ~= oFuncs.InspectAddonCurrent() then return end
	if nkRBConfig.combatOnly == true and data.isSecure == false then return end
	
	local setList = _internal.getSetList()
	
	for cdKey, cdDetails in pairs (cooldowns) do
		
		for setType, thisSet in pairs(setList) do
		
			for triggerId, triggerDetails in pairs(thisSet.trigger) do
				
				if triggerDetails.cdType ~= nil and triggerDetails.sId == cdKey then
					local icon = uiElements.icons[thisSet.icons[triggerId].uiId]
					if icon ~= nil then icon:SetVisible(false) end
				end
			end
		end
	end

end

local function _fctCooldownEnd(_, addon, cooldowns)

	if addon ~= oFuncs.InspectAddonCurrent() then return end
	if nkRBConfig.combatOnly == true and data.isSecure == false then return end
	
	local setList = _internal.getSetList()
	
	for cdKey, cdDetails in pairs (cooldowns) do
		
		for setType, thisSet in pairs(setList) do
		
			for triggerId, triggerDetails in pairs(thisSet.trigger) do
				
				if triggerDetails.cdType ~= nil and triggerDetails.sId == cdKey then
					local details = nkRBCache[_internal.getCacheKey(triggerDetails)]
					local icon = _internal.displayOrCreateIcon(setType, _internal.getActiveSet(setType), triggerId, triggerDetails, thisSet.icons[triggerId], details.titel, details.description)
					icon:SetTimer("")
				end
			end
		end
	end

end

local function _fctCooldownChange (_, addon, cooldowns)

	if addon ~= oFuncs.InspectAddonCurrent() then return end
	if nkRBConfig.combatOnly == true and data.isSecure == false then return end
	
	local setList = _internal.getSetList()
	
	for cdKey, cdDetails in pairs (cooldowns) do
		
		for setType, thisSet in pairs(setList) do
			
			for triggerId, triggerDetails in pairs(thisSet.trigger) do
				
				if triggerDetails.cdType ~= nil and triggerDetails.sId == cdKey then
		
					local iconDef = thisSet.icons[triggerId]
					local icon = uiElements.icons[iconDef.uiId]
		
					local checkCooldown = true
		
					if icon == nil then
						checkCooldown = false -- user didn't create an icon for an activated cooldown
					elseif iconDef.useDefaults == false and iconDef.showTimer == false then
						checkCooldown = false
					elseif iconDef.useDefaults == true and nkRBConfig.iconDefaults.showTimer == false then
						checkCooldown = false
					end
					
					if checkCooldown == true then
						local warnDurationLessThan = nkRBConfig.iconDefaults.warnDurationLessThan
						if iconDef ~= nil then warnDurationLessThan = iconDef.warnDurationLessThan end
					
						if cdDetails.remaining < warnDurationLessThan then
							local details = nkRBCache[_internal.getCacheKey(triggerDetails)]
							local icon = _internal.displayOrCreateIcon(setType, _internal.getActiveSet(setType), triggerId, triggerDetails, iconDef, details.titel, details.description)
						
							if cdDetails.remaining >= 1 then 
								icon:SetTimer(tostring(EnKai.tools.math.round(cdDetails.remaining, 0)))
							else
								icon:SetTimer(string.format("%0.1f", cdDetails.remaining))
							end
						end
					end
					
				end
			end
		
		end
	end

end

local function _fctUnitChange (_, unit, unitType)
	
	local setList = _internal.getSetList()
	
	for setType, thisSet in pairs(setList) do
		for triggerId, triggerDetails in pairs(thisSet.trigger) do
			if triggerDetails.unitType == unitType then
				local iconDef = thisSet.icons[triggerId]
				local icon = uiElements.icons[iconDef.uiId]
				if icon ~= nil then icon:SetVisible(false) end
			end
		end
	end
	
	if unit ~= false then
		EnKai.BuffManager.initUnitBuffs(unit)
		_internal.CheckMissingBuffs(unitType, '_fctPlayerTargetChange')
	end
	
end

local function _fctInitEvents()

	if _eventsInit then return end

	Command.Event.Attach(EnKai.events["EnKai.Unit"].Change, _fctUnitChange, "nkRebuff.EnKai.Unit.Change")
	EnKai.unit.subscribe('player.target')
	EnKai.unit.subscribe('focus')
	
	Command.Event.Attach(EnKai.events["EnKai.BuffManager"].Add, _fctBuffAdd, "nkRebuff.EnKai.BuffManager.Add")
	Command.Event.Attach(EnKai.events["EnKai.BuffManager"].Change, _fctBuffChange, "nkRebuff.EnKai.BuffManager.Change")
	Command.Event.Attach(EnKai.events["EnKai.BuffManager"].Remove, _fctBuffRemove, "nkRebuff.EnKai.BuffManager.Remove")
	
	--Command.Event.Attach(Event.System.Update.Begin, _internal.systemUpdate, "nkRebuff.System.Update.Begin")
	
	Command.Event.Attach(EnKai.events["EnKai.CDManager"].Start, _fctCooldownBegin, "nkRebuff.EnKai.CDManager.Start")
	Command.Event.Attach(EnKai.events["EnKai.CDManager"].Update, _fctCooldownChange, "nkRebuff.EnKai.CDManager.Update")
	Command.Event.Attach(EnKai.events["EnKai.CDManager"].Stop, _fctCooldownEnd, "nkRebuff.EnKai.CDManager.Stop")

	_eventsInit = true

end

---------- addon internal function block ---------

function _internal.UnitAvailable(_, unit)

	for k, v in pairs (unit) do
		if v == 'player' then
			if _eventsInit == false then
				_fctInitEvents()
				
				_internal.CheckMissingBuffs('player', '_internal.UnitAvailable')
				_internal.CheckCooldownsReady()
				_internal.setReBuffMacro()
				_internal.EventSubscriptions("mainSet", nil, nkRBConfig.activeSet)
				
			end

		elseif v == 'player.pet' then
			_internal.CheckMissingBuffs('player.pet', '_internal.UnitAvailable')
		end
	end

end

function _internal.GetSystemBuffID (unit, buffKey)

	local buffDetails = nil
	
	if unit == 'player' then
		buffDetails = EnKai.BuffManager.GetUnitBuffList(EnKai.unit.getUnitIDByType('player'))
	elseif unit == 'player.pet' then
		buffDetails = EnKai.BuffManager.GetUnitBuffList(EnKai.unit.getUnitIDByType('player.pet'))
	elseif unit == 'player.target' then
		buffDetails = EnKai.BuffManager.GetUnitBuffList(EnKai.unit.getUnitIDByType('player.target'))
	elseif _fctIsValidUnit(unit) then
		buffDetails = EnKai.BuffManager.GetUnitBuffList(unit)
	end
	
	if buffDetails == nil then return nil end
	
	for k, v in pairs(buffDetails) do
		--local thisBuffKey = v.type or v.name
		if v.key == buffKey then return k end
	end
	
	return nil

end