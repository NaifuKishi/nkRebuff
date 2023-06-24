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

function _ui.infoBlock ()

	local mask = EnKai.uiCreateFrame('nkMask', '_ui.infoBlock', privateVars.uiElements.context)
	mask:SetWidth(200)
	mask:SetHeight(50)
	
	local border = EnKai.uiCreateFrame('nkFrame', '_ui.infoBlock.border', mask)
	local inner = EnKai.uiCreateFrame('nkFrame', '_ui.infoBlock.inner', border)
	local header = EnKai.uiCreateFrame('nkText', '_ui.infoBlock.header', inner)
	local desc = EnKai.uiCreateFrame('nkText', '_ui.infoBlock.desc', inner)
	
	border:SetPoint("TOPLEFT", mask, "BOTTOMLEFT", 0, 1)
	border:SetBackgroundColor(0.925, 0.894, 0.741, 1)
	border:SetWidth(200)
	border:SetHeight(50)
	
	inner:SetPoint("TOPLEFT", border, "TOPLEFT", 1, 1)
	inner:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, -1)
	inner:SetBackgroundColor(0, 0, 0, 1)
	
	header:SetPoint ("TOPLEFT", inner, "TOPLEFT")
	header:SetWidth (198)
	header:SetHeight(20)
	header:SetFontSize(16)
	header:SetFontColor(0.882, 0.776, 0.428, 1)
	
	desc:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 5)
	desc:SetWidth(200)
	desc:SetWordwrap(true)
	desc:SetHeight(26)
	desc:SetFontSize(13)
	desc:SetFontColor(1,1,1,1)
	
	function mask:SetHeader(newHeader)
		header:SetText(newHeader)
	end
	
	function mask:SetDescription (newDesc)
		desc:ClearAll()
		desc:SetWidth(200)
		desc:SetText(newDesc, true)		
		desc:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 5)
		mask:SetHeight(desc:GetHeight() + 26 + 4)
		border:SetHeight(desc:GetHeight() + 26 + 4)
	end
	
	local oSetVisible = mask.SetVisible
	
	function mask:SetVisible(flag)
		if flag == false then 
			oSetVisible(self, false)
			return
		end
		
		border:SetPoint("TOPLEFT", mask, "TOPLEFT", 0, mask:GetHeight())

		local maskCoRoutine = coroutine.create(
		   function ()
				for idx = 1, mask:GetHeight(), 1 do
					border:SetPoint("TOPLEFT", mask, "TOPLEFT", 0, mask:GetHeight() - idx)					
					coroutine.yield(idx)
				end
		end)

		EnKai.coroutines.add( { func = maskCoRoutine, counter = mask:GetHeight(), active = true })
		
		oSetVisible(self, true)
	end	
	
	return mask

end