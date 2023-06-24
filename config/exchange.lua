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

function _ui.ConfigTabExchange (parent)
	
	local name = parent:GetName() .. '.tabExchange'
	
	local tabPane = EnKai.uiCreateFrame('nkFrame', name, parent)
	local editField, exportButton, importButton, exportHint, setTypeSelect, setSelect, shareButton
	
	local function _fctUpdateSetSelect()
	
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
	end
	
	local function _fctExport()
	
		local setSel = setSelect:GetSelectedValue()
		local data = setTypeSelect:GetSelectedValue()
		
		local rbSet
		
		if setTypeSelect:GetSelectedValue() == 'mainSet' then
			data = data .. ";" .. nkRBSetMain[setSel].name
			data = data .. ";return {" .. EnKai.tools.table.serialize (nkRBSetMain[setSel]) .. "}"
			
			rbSet = nkRBSetMain[setSel]
		else
			data = data .. ";" .. nkRBSetSub[setSel].name
			data = data .. ";return {" .. EnKai.tools.table.serialize (nkRBSetSub[setSel]) .. "}"
			
			rbSet = nkRBSetSub[setSel]
		end
		
		local cacheData = {}
		
		for triggerId, triggerDetails in pairs(rbSet.trigger) do
			local cacheId = _internal.getCacheKey(triggerDetails)
			if cacheId ~= nil then cacheData[cacheId] = nkRBCache[cacheId] end
		end
		
		data = data .. ";return {" .. EnKai.tools.table.serialize (cacheData) .. "}"
	
		local checksum, compressed = EnKai.zip.compress (data:gsub('\\', '/'))
		
		local lineTable = {}
		for idx = 1, compressed:len(), 100 do table.insert(lineTable, compressed:sub(idx, idx + 99)) end
		
		local exportString = table.concat(lineTable, "\n")
		editField:SetText(checksum .. "!!" .. exportString)
		editField:SetKeyFocus(true)
		editField:SetSelection(1, string.len(checksum .. "!!" .. exportString))
	end
	
	local function _fctStoreImported(importTable, createNewflag)
		
		if createNewflag == true then
		
			if importTable[1] == 'mainSet' then
				table.insert(nkRBSetMain, { name = importTable[2], role = 0, trigger = {}, icons = {} })
			else
				table.insert(nkRBSetSub, { name = importTable[2], role = 0, trigger = {}, icons = {} })
			end
			
		end
		
		local rbSet
		if importTable[1] == 'mainSet' then
			rbSet = nkRBSetMain
		else
			rbSet = nkRBSetSub
		end
		
		local overwriteSet = 1
		
		for k, v in pairs (rbSet) do
			if v.name == importTable[2] then break end
			overwriteSet = overwriteSet + 1
		end
	
		local setLoad = loadstring (importTable[3])
		local sets = setLoad()
		
		if importTable[1] == 'mainSet' then
			nkRBSetMain[overwriteSet] = sets
			nkRBSetMain[overwriteSet].name = importTable[2]
		else
			nkRBSetSub[overwriteSet] = sets
			nkRBSetSub[overwriteSet].name = importTable[2]
		end
		
		local cacheLoad = loadstring (importTable[4])
		local cache = setLoad()
		
		for key, cacheDetails in pairs(cache) do
			nkRBCache[key] = cacheDetails
		end
		
		uiElements.configUI:GetTabPane():GetPaneInfo()[1].frame:UpdateMainSetSelectValues()
		uiElements.configUI:GetTabPane():GetPaneInfo()[1].frame:UpdateSubSetSelectValues()
		uiElements.configUI:GetTabPane():GetPaneInfo()[3].frame:UpdateSetSelect()
		_fctUpdateSetSelect()
	end
	
	local function _fctImport()
	
		local data = editField:GetText()
		
		local start = string.find(data, "!!")
		
		if start == nil then
			EnKai.ui.messageDialog (privateVars.langTexts.importErrorFormat)
			return
		end
		
		local checksum = data:sub(1, start-1)
		local temp = data:sub(start+2)
		local compressed = temp:gsub('\n', ""):gsub('\r', "")
		
	  	if EnKai.zip.checksum(compressed) ~= checksum then
			EnKai.ui.messageDialog (privateVars.langTexts.importErrorChecksum)
	  		return
	  	end
	  	
	  	local uncompressed = EnKai.zip.uncompress (compressed)
		
	  	local importTable = {}
	  	for entry in string.gmatch(uncompressed, "[^;]+") do
	  		table.insert(importTable, entry)
	  	end	
	  	
	  	local duplicateName = false
	  	
		local rbSet
		if importTable[1] == 'mainSet' then
			rbSet = nkRBSetMain
		else
			rbSet = nkRBSetSub
		end
		
	  	for k, v in pairs (rbSet) do
	  		if v.name == importTable[2] then
	  			duplicateName = true
	  			break
	  		end	
	  	end
	  	
	  	if duplicateName == false then
	  		_fctStoreImported(importTable, true)
	  	else
	  		local yesFunc = function () _fctStoreImported(importTable, false) end
			local noFunc = function ()

				EnKai.ui.confirmDialog (privateVars.langTexts.messages.importAsNewSet, function()
					importTable[2] = string.format(privateVars.langTexts.genericSettings.copiedSetName, importTable[2]) 
					_fctStoreImported(importTable, true)
				end, function() return end)
				
			end 
			
			EnKai.ui.confirmDialog (string.format(privateVars.langTexts.messages.importDuplicateSet, importTable[2]), yesFunc, noFunc)
	  	end 
	  	
	end
	
	function tabPane:build ()
		
		editField = EnKai.uiCreateFrame("nkTextfield", name .. '.editField', tabPane)
		exportButton = EnKai.uiCreateFrame("nkButtonMetro", name .. ".exportButton", tabPane)
		importButton = EnKai.uiCreateFrame("nkButtonMetro", name .. ".importButton", tabPane)
		--shareButton = EnKai.uiCreateFrame("nkButtonMetro", name .. ".shareButton", tabPane)
		
		setTypeSelect = EnKai.uiCreateFrame("nkRadioButton", name .. '.setTypeSelect', tabPane)
		setTypeSelect:SetSelection(privateVars.langTexts.setTypeSelectList)
		setTypeSelect:SetSelectedValue('mainSet')
		setTypeSelect:SetText(privateVars.langTexts.setExportTypeSelect)
		setTypeSelect:SetLabelWidth(100)
		setTypeSelect:SetWidth(300)
		setTypeSelect:SetLayer(9)
		setTypeSelect:SetPoint("TOPLEFT", tabPane, "TOPLEFT")
		
		Command.Event.Attach(EnKai.events[setTypeSelect:GetName()].RadiobuttonChanged, function()
			
			_fctUpdateSetSelect()
			
		end, setTypeSelect:GetName()..".RadiobuttonChanged")
		
		setSelect = EnKai.uiCreateFrame("nkComboBox", name .. '.setSelect', tabPane)
		setSelect:SetSelectedValue(nkRBConfig.activeSet, false)
		setSelect:SetText(privateVars.langTexts.setExportSelect)
		setSelect:SetLabelWidth(100)
		setSelect:SetWidth(300)
		setSelect:SetLayer(8)
		setSelect:SetPoint("TOPLEFT", setTypeSelect, "BOTTOMLEFT", 0, 8)
				
		exportButton:SetPoint("TOPLEFT", setSelect, "BOTTOMLEFT", 0, 20)
		exportButton:SetText(privateVars.langTexts.exportButton)
		--exportButton:SetWidth(200)
		exportButton:SetScale(.8)
		exportButton:SetIcon("EnKai", "gfx/icons/leave.png")
		
		importButton:SetPoint("CENTERLEFT", exportButton, "CENTERRIGHT", 10, 0)
		importButton:SetText(privateVars.langTexts.importButton)
		--importButton:SetWidth(200)
		importButton:SetScale(.8)
		importButton:SetIcon("EnKai", "gfx/icons/join.png")
		
		-- shareButton:SetPoint("BOTTOMRIGHT", editField, "TOPRIGHT", 0, -10)
		-- shareButton:SetText(privateVars.langTexts.shareButton)
		-- shareButton:SetScale(.8)
		-- shareButton:SetIcon("EnKai", "gfx/icons/announce.png")
		
		editField:SetPoint("TOPLEFT", exportButton, "BOTTOMLEFT", -1, 10)
		editField:SetWidth(tabPane:GetWidth())
		editField:SetHeight(300)
		
		exportButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			_fctExport()
		end, name .. '.exportButton.Left.Click')
		
		importButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
			_fctImport()
		end, name .. '.importButton.Left.Click')
		
		exportHint = EnKai.uiCreateFrame('nkInfoText', name .. '.exportHint', tabPane)
		exportHint:SetPoint("TOPRIGHT", tabPane, "TOPRIGHT")
		exportHint:SetFontSize(12)
		exportHint:SetWidth(400)
		exportHint:SetHeight(60)
		exportHint:SetType('info')
		exportHint:SetIconAlign('top')
		exportHint:SetText(privateVars.langTexts.exportHint)
		
		_fctUpdateSetSelect()
		
	end
	
	return tabPane

end