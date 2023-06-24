local addonInfo, privateVars = ...

---------- init namespace ---------

local uiElements	= privateVars.uiElements
local _internal		= privateVars.internal
local data			= privateVars.data
local oFuncs		= privateVars.oFuncs

---------- init local variables ---------

---------- init variables ---------

---------- local function block ---------

local function _fctGetStoredBuffData (unit)

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
	
	return buffDetails

end

---------- addon internal function block ---------

function _internal.CheckMissingBuffs(unitType, debugSource)

	if oFuncs.InspectUnitDetail(unitType) == nil then return end

	if data.overrideCombatCheck ~= true and nkRBConfig.combatOnly == true and data.isSecure == false then return false end
	
	local setList = _internal.getSetList()
	
	for setType, thisSet in pairs(setList) do
		for id, triggerDetails in pairs(thisSet.trigger) do

			if triggerDetails.unitType == unitType or triggerDetails.unitTypeKey == unitType then
				if _internal.CheckDisplay(triggerDetails, nil, nil, _internal.GetWarnDuration(thisSet.icons[id]), '_internal.CheckMissingBuffs') then
					_internal.displayOrCreateIcon (setType, _internal.getActiveSet(setType), id, triggerDetails, thisSet.icons[id])
				end
			end
		end
	end

end

function _internal.GetWarnDuration(iconDef)

	local warnDurationLessThan = nkRBConfig.iconDefaults.warnDurationLessThan
		
	if iconDef.useDefaults == false and iconDef.showTimer == false then
		return
	elseif iconDef.useDefaults == true and nkRBConfig.iconDefaults.showTimer == false then
		return
	end
	
	if not iconDef.useDefaults then warnDurationLessThan = iconDef.warnDurationLessThan end
	
	return warnDurationLessThan

end

function _internal.CheckCooldownsReady()

	if nkRBConfig.combatOnly == true and data.isSecure == false then return end
	
	local setList = _internal.getSetList()
		
	for setType, thisSet in pairs(setList) do
	
		for id, triggerDetails in pairs(thisSet.trigger) do
	
			if triggerDetails.sType == 'cooldown' then
				
				if _internal.CheckDisplay(triggerDetails, nil, nil, nil, '_internal.CheckCooldownsReady') then
					_internal.displayOrCreateIcon (setType, _internal.getActiveSet(setType), id, triggerDetails, thisSet.icons[id])
				end
			
			end
		end
	end


end

function _internal.CheckDisplay(trigger, stackCount, remainingTime, warnDuration, debugSource)

	if trigger.active == false then return false end
	
	if trigger.sType == 'coolown' then
		if EnKai.cdManager.isCooldownActive(trigger.sId) ~= trigger.showIfActive then return false end
	else
	
		local unitType = trigger.unitType
		if trigger.unitTypeKey ~= nil then unitType = trigger.unitTypeKey end
		
		if EnKai.unit.getUnitIDByType(unitType) == nil then return false end
		
		for _, thisUnitType in pairs(EnKai.unit.getUnitIDByType(unitType)) do
			
			local isActive = EnKai.BuffManager.isBuffActive(thisUnitType, trigger.sId)
			
			if isActive ~= (trigger.showIfActive or false) then 
			
				if not isActive then return false end
				
				if warnDuration == nil then return false end
				
				if remainingTime == nil then
					local details = EnKai.BuffManager.GetBuffDetails(thisUnitType, trigger.sId)
					if details ~= nil then remainingTime = details.remaining end
				end
				
				if remainingTime == nil then
					return false
				elseif remainingTime > 0 and remainingTime > warnDuration then
					return false
				end
			end
		end
	end
	
	if trigger.stackTrigger == nil or trigger.stackTrigger == "na" then return true end
	
	if trigger.stackCounter == nil then trigger.stackCounter = 0 end
	
	if trigger.stackTrigger == "less" then
		if stackCount ~= nil and stackCount < trigger.stackCounter then return true else return false end
	elseif trigger.stackTrigger == "greater" then
		if stackCount ~= nil and stackCount > trigger.stackCounter then  return true else return false end
	elseif trigger.stackTrigger == "equal" then
		if stackCount ~= nil and stackCount == trigger.stackCounter then return true else return false end
	end
	
	return false
	
end