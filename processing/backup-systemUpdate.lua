local addonInfo, privateVars = ...

---------- init namespace ---------

local uiElements	= privateVars.uiElements
local _internal		= privateVars.internal
local data			= privateVars.data

---------- init local variables ---------

---------- init variables ---------

---------- local function block ---------

---------- addon internal function block ---------

function _internal.systemUpdate()

	if nkRBConfig == nil then return end

	if nkRBConfig.active == false then return end
	if privateVars.uiElements.configUI ~= nil and privateVars.uiElements.configUI:GetVisible() == true then return end

	if nkRBConfig.combatOnly == false or data.isSecure == true then
	
		-- check ob der letzte Update mehr länger her ist als throttle
	
		if privateVars.forceUpdate ~= true then
			if privateVars.lastIconUpdate == nil then
				privateVars.lastIconUpdate = Inspect.Time.Real()
				privateVars.forceUpdate = true
			else
				local tmpTime = Inspect.Time.Real()
				if EnKai.tools.math.round((tmpTime - privateVars.lastIconUpdate), 1) > nkRBConfig.throttle then privateVars.forceUpdate = true end
			end
		end
		
		if privateVars.forceUpdate == true then	
		
			privateVars.lastIconUpdate = Inspect.Time.Real()
			
			-- checks buffs on player to display timer and stack
			
			if nkRBSets[nkRBConfig.activeSet].buffsPlayer ~= nil then
			
				for id, details in pairs (nkRBSets[nkRBConfig.activeSet].buffsPlayer) do
					if details.active == true then
						if nkRBIcons[nkRBConfig.activeSet].buffsPlayer[id] == nil then
							nkRBSets[nkRBConfig.activeSet].buffsPlayer[id].active = false
						else						
							if EnKai.BuffManager.isBuffActive(EnKai.unit.getUnitIDByType('player'), id) == false then						
								-- ok so this item is to be tracked and missing!
								-- probably we need to do nothing here
							else
								-- performance check - only do processing if counter is to be displayed anyway
							
								local checkBuff = true
								if nkRBIcons[nkRBConfig.activeSet].buffsPlayer[id] == nil then
									checkBuff = false -- user didn't create an icon for an activated buff
								elseif nkRBIcons[nkRBConfig.activeSet].buffsPlayer[id].useDefaults == false and nkRBIcons[nkRBConfig.activeSet].buffsPlayer[id].showTimer == false then
									checkBuff = false
								elseif nkRBIcons[nkRBConfig.activeSet].buffsPlayer[id].useDefaults == true and nkRBConfig.iconDefaults.showTimer == false then
									checkBuff = false
								end
								
								if checkBuff == true then
									-- need to check remaining and update stack
									local systemID = _internal.GetSystemBuffID (EnKai.unit.getUnitIDByType('player'), id)
									
									if systemID ~= nil then									
										--local buffDetails = Inspect.Buff.Detail(privateVars.buffs.units.player, systemID)
										local buffDetails = privateVars.buffCache[systemID]
										
										if buffDetails ~= nil and buffDetails.begin ~= nil then -- no need to check unknown buffs or such without a duration
											local warnDurationLessThan = nkRBConfig.iconDefaults.warnDurationLessThan
											if nkRBIcons[nkRBConfig.activeSet].buffsPlayer[id] ~= nil then
												warnDurationLessThan = nkRBIcons[nkRBConfig.activeSet].buffsPlayer[id].warnDurationLessThan
											end
											
											local remaining = buffDetails.duration - (Inspect.Time.Frame() - buffDetails.begin)
											if remaining < 0 then
												-- buff timer out of sync - this is a workaround. got to find the real cause sometime
												buffDetails = Inspect.Buff.Detail ('player', systemID)
												
												if buffDetails == nil then 
													nkRebuff.processBuffRemove(EnKai.unit.getUnitIDByType('player'), systemID)
													remaining = 9999 -- so that the icon will not be shown
												else
													privateVars.buffCache[systemID] = buffDetails
													remaining = buffDetails.duration - (Inspect.Time.Frame() - buffDetails.begin)
												end											
											end
											
											if remaining < warnDurationLessThan and remaining > 0 then
											--if buffDetails.remaining ~= nil and buffDetails.remaining < warnDurationLessThan then
												local icon = _internal.displayOrCreateIcon ('buffsPlayer', id)
												icon:SetTimer(tostring(EnKai.tools.math.round(remaining, 0)))
												
												if nkRBIcons[nkRBConfig.activeSet].buffsPlayer[id].showStack == true then																							
													icon:SetStack(buffDetails.stack)
												end
											end
										end
									end
								end
							end
						end
					end
				end
				
			end
			
			-- checks debuffs on target to display timer and stack
			
			if nkRBSets[nkRBConfig.activeSet].debuffsTarget ~= nil then
			
				for id, details in pairs (nkRBSets[nkRBConfig.activeSet].debuffsTarget) do
					if details.active == true then
						if nkRBIcons[nkRBConfig.activeSet].debuffsTarget[id] == nil then
							nkRBSets[nkRBConfig.activeSet].debuffsTarget[id].active = false
						else	
							if EnKai.BuffManager.isBuffActive(EnKai.unit.getUnitIDByType('player.target'), id) == false then						
								-- ok so this item is to be tracked and missing!
								-- probably we need to do nothing here
							else
								-- performance check - only do processing if counter is to be displayed anyway
								local checkDebuff = true
								if nkRBIcons[nkRBConfig.activeSet].debuffsTarget[id] == nil then
									checkDebuff = false -- user didn't create an icon for an activated buff
								elseif nkRBIcons[nkRBConfig.activeSet].debuffsTarget[id].useDefaults == false and nkRBIcons[nkRBConfig.activeSet].debuffsTarget[id].showTimer == false then
									checkDebuff = false
								elseif nkRBIcons[nkRBConfig.activeSet].debuffsTarget[id].useDefaults == true and nkRBConfig.iconDefaults.showTimer == false then
									checkDebuff = false
								end
								
								if checkDebuff == true then
								
									-- need to check remaining
									local systemID = _internal.GetSystemBuffID (EnKai.unit.getUnitIDByType('player.target'), id)
									
									if systemID ~= nil then
										--local debuffDetails = Inspect.Buff.Detail('player.target', systemID)							
										local debuffDetails = privateVars.buffCache[systemID]
										
										if debuffDetails ~= nil and debuffDetails.begin ~= nil then -- no need to check unknown buffs or such without a duration
											local warnDurationLessThan = nkRBConfig.iconDefaults.warnDurationLessThan
											if nkRBIcons[nkRBConfig.activeSet].debuffsTarget[id] ~= nil then
												warnDurationLessThan = nkRBIcons[nkRBConfig.activeSet].debuffsTarget[id].warnDurationLessThan
											end
										
											local remaining = debuffDetails.duration - (Inspect.Time.Frame() - debuffDetails.begin)
											if remaining < 0 then
												-- debuff timer out of sync - this is a workaround. got to find the real cause sometime
												debuffDetails = Inspect.Buff.Detail ('player.target', systemID)
												
												if debuffDetails == nil then 
													nkRebuff.processBuffRemove(EnKai.unit.getUnitIDByType('player.target'), systemID)
													remaining = 9999 -- so that the icon will not be shown
												else
													privateVars.buffCache[systemID] = debuffDetails
													remaining = debuffDetails.duration - (Inspect.Time.Frame() - debuffDetails.begin)
												end											
											end
										
											if remaining < warnDurationLessThan then
											--if debuffDetails.remaining ~= nil and debuffDetails.remaining < warnDurationLessThan then
												local icon = _internal.displayOrCreateIcon ('debuffsTarget', id)
												icon:SetTimer(tostring(EnKai.tools.math.round(remaining, 0)))
												
												if nkRBIcons[nkRBConfig.activeSet].debuffsTarget[id].showStack == true then																							
													icon:SetStack(debuffDetails.stack)
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			
			-- checks cooldowns
			
			if nkRBSets[nkRBConfig.activeSet].cooldownsPlayer ~= nil then
			
				for id, details in pairs (nkRBSets[nkRBConfig.activeSet].cooldownsPlayer) do
					if details.active == true then
						if nkRBIcons[nkRBConfig.activeSet].cooldownsPlayer[id] == nil then
							nkRBSets[nkRBConfig.activeSet].cooldownsPlayer[id].active = false
						else	
							if EnKai.cdManager.isCooldownActive(id) == false then						
								-- In difference to debuffs and buffs we need to do something here cause the cooldown is ready!
								--print ('system update')
								local icon = _internal.displayOrCreateIcon ('cooldownsPlayer', id)
								icon:SetTimer("")
								icon:SetStack("")
							else
								-- performance check - only do processing if counter is to be displayed anyway
							
								local checkCooldown = true
								if nkRBIcons[nkRBConfig.activeSet].cooldownsPlayer[id] == nil then
									checkCooldown = false -- user didn't create an icon for an activated cooldown
								elseif nkRBIcons[nkRBConfig.activeSet].cooldownsPlayer[id].useDefaults == false and nkRBIcons[nkRBConfig.activeSet].cooldownsPlayer[id].showTimer == false then
									checkCooldown = false
								elseif nkRBIcons[nkRBConfig.activeSet].cooldownsPlayer[id].useDefaults == true and nkRBConfig.iconDefaults.showTimer == false then
									checkCooldown = false
								end
								
								if checkCooldown == true then
							
									-- need to check remaining
									
									local abilityDetails = EnKai.cdManager.getCooldownDetails("ability", id)
									
									if abilityDetails ~= nil then
										local warnDurationLessThan = nkRBConfig.iconDefaults.warnDurationLessThan
										if nkRBIcons[nkRBConfig.activeSet].cooldownsPlayer[id] ~= nil then
											warnDurationLessThan = nkRBIcons[nkRBConfig.activeSet].cooldownsPlayer[id].warnDurationLessThan
										end
										
										local remaining = EnKai.tools.math.round(abilityDetails.cooldown - (Inspect.Time.Frame() - abilityDetails.currentCooldownBegin), 0)
										
										if remaining < warnDurationLessThan then
											--print ('system update - duration check')
											local icon = _internal.displayOrCreateIcon ('cooldownsPlayer', id)
											icon:SetTimer(tostring(remaining))									
										end
									end
								end
							end
						end
					end
				end			
			end

			privateVars.forceUpdate = false
		end
	end

end