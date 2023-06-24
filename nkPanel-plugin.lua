local addonInfo, privateVars = ...

---------- init namespace ---------

local uiElements	= privateVars.uiElements
local _internal		= privateVars.internal

---------- init local variables ---------

---------- init variables ---------

---------- local function block ---------

---------- addon internal function block ---------

function _internal.nkPanelPlugin (menuItems)

	local plugin = nkPanel.api.plugin('nkRebuff', true, false)

	plugin:SetTitle('nkRebuff')
	plugin:SetSecureMode('restricted')
	
	plugin:SetThumb('nkRebuff', 'gfx/nkPanelIcon.png')

	local body = plugin:CreateBody()
	
	body:SetSecureMode('restricted')
	
	local menu = EnKai.uiCreateFrame("nkMenu", 'nkRebuff.panelMenu', body)
		
	menu:SetFontSize(13)
	menu:SetWidth(120)
	menu:SetBackgroundColor(0, 0, 0, 0)
	menu:SetLabelColor(1, 1, 1, 1)
	menu:SetBorderColor(0, 0, 0, 0)
	menu:SetPoint("TOPLEFT", body, "TOPLEFT", 2, 2)
	
	local items = {}
	local subMenus
	
--	function button:AddAddon(addonName, subMenuItems, mainFunc)

	for k, v in pairs(menuItems) do				
		if v.seperator == true then
			menu:AddSeparator()					
		elseif v.callBack ~= nil then
			menu:AddEntry({ closeOnClick = true, label = v.label, macro = v.macro, callBack = function() v.callBack() end })
		else
			menu:AddEntry({ closeOnClick = true, label = v.label, macro = v.macro, callBack = nil })
		end
	end
	
	body:SetHeight(menu:GetHeight()+4)
	body:SetWidth(menu:GetWidth()+4)
	
	function plugin:GetMenu() return menu end
	function plugin:GetBody() return body end
	
	return plugin

end