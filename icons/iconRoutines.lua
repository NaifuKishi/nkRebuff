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

local function _fctUpdateIcon(icon, iconData)

	icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", iconData.xpos, iconData.ypos)
	
	if iconData.useDefaults == true then
	
		icon:ShowLabel(nkRBConfig.iconDefaults.showLabel)
		icon:ShowBorder(nkRBConfig.iconDefaults.showBorder)
		icon:ShowTimer(nkRBConfig.iconDefaults.showTimer)
		icon:ShowStack(false)
		icon:SetScale(nkRBConfig.iconDefaults.scale / 100)
		
		icon:SetBorderColor (nkRBConfig.iconDefaults.borderColor[1], nkRBConfig.iconDefaults.borderColor[2], nkRBConfig.iconDefaults.borderColor[3], nkRBConfig.iconDefaults.borderColor[4])
		icon:SetLabelColor (nkRBConfig.iconDefaults.labelColor[1], nkRBConfig.iconDefaults.labelColor[2], nkRBConfig.iconDefaults.labelColor[3], nkRBConfig.iconDefaults.labelColor[4])
		icon:SetTimerColor (nkRBConfig.iconDefaults.timerColor[1], nkRBConfig.iconDefaults.timerColor[2], nkRBConfig.iconDefaults.timerColor[3], nkRBConfig.iconDefaults.timerColor[4], 
		                    nkRBConfig.iconDefaults.timerOutlineColor[1],nkRBConfig.iconDefaults.timerOutlineColor[2],nkRBConfig.iconDefaults.timerOutlineColor[3])
		icon:SetStackColor (nkRBConfig.iconDefaults.stackColor[1], nkRBConfig.iconDefaults.stackColor[2], nkRBConfig.iconDefaults.stackColor[3], nkRBConfig.iconDefaults.stackColor[4])
	else
		icon:ShowLabel(iconData.showLabel)
		icon:ShowBorder(iconData.showBorder)
		icon:ShowTimer(iconData.showTimer)
		
		icon:SetScale(iconData.scale / 100)
		
		icon:SetBorderColor (iconData.borderColor[1], iconData.borderColor[2], iconData.borderColor[3], iconData.borderColor[4])
		icon:SetLabelColor (iconData.labelColor[1], iconData.labelColor[2], iconData.labelColor[3], iconData.labelColor[4])
		icon:SetTimerColor (iconData.timerColor[1], iconData.timerColor[2], iconData.timerColor[3], iconData.timerColor[4],
		                    iconData.timerOutlineColor[1],iconData.timerOutlineColor[2],iconData.timerOutlineColor[3])
		icon:SetStackColor (iconData.stackColor[1], iconData.stackColor[2], iconData.stackColor[3], iconData.stackColor[4])
	end
	
	icon:ShowStack(iconData.showStack)
	
	icon:SetTexture(iconData.textureType, iconData.texturePath)
	icon:SetLabel(_internal.ComputeLabel(iconData.label))
	
	icon:SetEffect (privateVars.effects[nkRBConfig.iconDefaults.effect])

end

---------- addon internal function block ---------

function _internal.ComputeLabel (label)

	if label == nil then return end

	if nkRBConfig.iconDefaults.shortLabels == true then
		local tempValue
		local shortenedText = ''
		if string.find (label, ' ') == nil and string.find(label, '-') ~= nil then
			--tempValue = EnKai.strings.split(label, '-')
			tempValue = EnKai.strings.split(label, '-')
		else
			tempValue = EnKai.strings.split(label, ' ')
			--tempValue = EnKai.strings.split(label, ' ')
		end
		
		for idx2 = 1, #tempValue, 1 do
			shortenedText = shortenedText .. string.sub (tempValue[idx2], 1, 1)
		end		
		return shortenedText
	else
		return label
	end

end

function _internal.displayOrCreateIcon (setType, activeSet, triggerId, trigger, iconDef, titel, desc)

	if iconDef == nil then return end
	
	local uiIcon = uiElements.icons[iconDef.uiId]
	--local cacheKey = _internal.getCacheKey (trigger)

	if uiIcon == nil then
		uiIcon = _internal.createIcon (setType, activeSet, triggerId, trigger, iconDef)
	elseif uiIcon:GetVisible() == true then
		if titel ~= nil or desc ~= nil then
			uiIcon:SetInfoBlock(titel, desc)
		end
			
		return uiIcon
	end
	
	uiIcon:SetTimer("")
	uiIcon:SetStack("")

	
	if titel ~= nil or desc ~= nil then
		uiIcon:SetInfoBlock(titel, desc)
	end
	
	uiIcon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", iconDef.xpos, iconDef.ypos)
	
	if uiIcon:GetVisible() ~= true then uiIcon:SetVisible(true) end
		
	uiIcon:SetAlpha(1)
	
	return uiIcon

end

function _internal.displayAllIcons(dragableFlag)
	
	local setList = _internal.getSetList()
	
	for setType, thisSet in pairs(setList) do
	
		for key, triggerDetails in pairs(thisSet.trigger) do

			local iconDef = thisSet.icons[key]
			local uiIcon = uiElements.icons[iconDef.uiId]
			
			if uiIcon == nil then
				local cache = nkRBCache[_internal.getCacheKey(triggerDetails)]
				if cache ~= nil then
					uiIcon = _internal.displayOrCreateIcon(setType, _internal.getActiveSet(setType), key, triggerDetails, iconDef, cache.name, cache.description)
				else
					uiIcon = _internal.displayOrCreateIcon(setType, _internal.getActiveSet(setType), key, triggerDetails, iconDef)
				end
			end

			uiIcon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", iconDef.xpos, iconDef.ypos)
			uiIcon:SetVisible(true)
			uiIcon:SetAlpha(1)
			uiIcon:SetDragable(dragableFlag)
		end
	end
	
end

function _internal.hideAllIcons()

	--nkRebuff.logDebug ("hide all icons of set " .. nkRBConfig.activeSet)
	
	for id, icon in pairs(uiElements.icons) do
		icon:SetVisible(false)
		icon:SetDragable(false)
	end

end

function _internal.createIcon (setType, activeSet, triggerId, trigger, iconDef)

	local icon = _ui.icon (iconDef.uiId, privateVars.uiElements.context)
	uiElements.icons[iconDef.uiId] = icon

	_fctUpdateIcon(icon, iconDef)
	
	icon:SetDragable(false)
	icon:SetValue('setType', setType)	
	icon:SetValue('activeSet', activeSet)
	icon:SetValue('triggerId', triggerId)
	
	return icon
	
end

function _internal.UpdateAllIcons()

	local setList = _internal.getSetList()
	
	for setType, thisSet in pairs(setList) do
		for key, triggerDetails in pairs(thisSet.trigger) do

			local iconDef = thisSet.icons[key]
			local uiIcon = uiElements.icons[iconDef.uiId]
			
			if uiIcon ~= nil then
				_fctUpdateIcon(uiIcon, iconDef)
			end
		end
	end

end
