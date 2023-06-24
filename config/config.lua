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

function _ui.Config ()

	local name = "nkRebuff.config"
	local config, tabPane, EnKaiLogo, closeButton, analyzerButton, recordedButton, versionText
	local paneTabSettings, paneTabTrigger, paneTabIconDefaults, paneTabExchange

	config = EnKai.uiCreateFrame("nkWindowMetro", name, uiElements.configContext)	
	tabPane = EnKai.uiCreateFrame("nkTabpaneMetro", name .. ".TabPane", config:GetContent())

	paneTabSettings = _ui.ConfigTabSettings(tabPane)
	paneTabTrigger = _ui.ConfigTabTrigger(tabPane)
	paneTabIconDefaults = _ui.ConfigTabIconDefaults(tabPane)
	paneTabExchange = _ui.ConfigTabExchange(tabPane)

	config:SetTitle(addonInfo.toc.Name)
	config:SetPoint("CENTER", UIParent, "CENTER")
	config:SetWidth(807)
	config:SetHeight(600)

	tabPane:SetBorder(false)
	tabPane:SetPoint("TOPLEFT", config:GetContent(), "TOPLEFT", 10, 10)
	tabPane:SetPoint("BOTTOMRIGHT", config:GetContent(), "BOTTOMRIGHT", -10, -50)

	tabPane:AddPane( { label = privateVars.langTexts.tabHeaderSettings, frame = paneTabSettings, initFunc = function() paneTabSettings:build() end}, false)
	tabPane:AddPane( { label = privateVars.langTexts.tabHeaderIconDefaults, frame = paneTabIconDefaults, initFunc = function() paneTabIconDefaults:build() end}, false)
	tabPane:AddPane( { label = privateVars.langTexts.tabHeaderTracking, frame = paneTabTrigger, initFunc = function() paneTabTrigger:build() end}, false)
	tabPane:AddPane( { label = privateVars.langTexts.tabHeaderExchange, frame = paneTabExchange, initFunc = function() paneTabExchange:build() end}, true)

	EnKaiLogo = EnKai.uiCreateFrame("nkTexture", name .. ".EnKaiLogo", config)
	EnKaiLogo:SetTextureAsync(EnKai.art.GetThemeLogo()[1],EnKai.art.GetThemeLogo()[2])
	EnKaiLogo:SetPoint("BOTTOMLEFT", config:GetContent(), "BOTTOMLEFT", 10, -5)
	EnKaiLogo:SetWidth(125)
	EnKaiLogo:SetHeight(33)

	closeButton = EnKai.uiCreateFrame("nkButtonMetro", name .. ".closeButton", config:GetContent())

	closeButton:SetPoint("BOTTOMRIGHT", config:GetContent(), "BOTTOMRIGHT", -10, -10)
	closeButton:SetText(privateVars.langTexts.btClose)
	closeButton:SetIcon("EnKai", "gfx/icons/close.png")
	closeButton:SetScale(.8)
	closeButton:SetLayer(9)

	Command.Event.Attach(EnKai.events[name .. ".closeButton"].Clicked, function (_, newValue)
		config:SetVisible(false)
		if uiElements.Analyzer ~= nil then uiElements.Analyzer:SetVisible(false) end
	end, name .. ".closeButton.Clicked")
	
	versionText = EnKai.uiCreateFrame("nkText", name .. ".versionText", config)
	versionText:SetFontSize(11)
	versionText:SetText(string.format(privateVars.langTexts.txtVersion, addonInfo.toc.Version))
	versionText:SetPoint("BOTTOMRIGHT", tabPane, "BOTTOMRIGHT", -5, -5)
	versionText:SetLayer(98)

	analyzerButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.analyzerButton', config:GetContent())	
	analyzerButton:SetText(privateVars.langTexts.analyze)
	analyzerButton:SetPoint("CENTERRIGHT", closeButton, "CENTERLEFT", -5, 0)
	analyzerButton:SetIcon("EnKai", "gfx/icons/scan.png")
	analyzerButton:SetScale(.8)
	analyzerButton:SetLayer(9)

	analyzerButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
		local flag = not _internal.analyzerActive()
		config:InitAnalyze(flag)
		_internal.initAnalyzer(flag)
	end, analyzerButton:GetName() .. 'UI.Input.Mouse.Left.Click')

	recordedButton = EnKai.uiCreateFrame('nkButtonMetro', name .. '.recordedButton', config:GetContent())
	recordedButton:SetText(privateVars.langTexts.recorded)
	recordedButton:SetPoint("CENTERRIGHT", analyzerButton, "CENTERLEFT", -5, 0)
	recordedButton:SetIcon("EnKai", "gfx/icons/matrix.png")
	recordedButton:SetScale(.8)
	recordedButton:SetLayer(9)

	recordedButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function ()
		
		if uiElements.Analyzer ~= nil and uiElements.Analyzer:GetVisible() then
			uiElements.Analyzer:SetVisible(false)
			config:InitAnalyze(false)
		else
		
			config:InitAnalyze(true)
			
			if uiElements.Analyzer == nil and data.buildAnalyzer ~= true then 
				data.buildAnalyzer = true
				EnKai.tools.perf.addToQueue(function() uiElements.Analyzer = _ui.Analyzer()  end)
			end

			EnKai.tools.perf.addToQueue(function() tabPane:SwitchToPane(3) end)
			EnKai.tools.perf.addToQueue(function() uiElements.Analyzer:SetVisible(true) end)
		end

	end, recordedButton:GetName() .. '.UI.Input.Mouse.Left.Click')

	local oSetVisible = config.SetVisible

	function config:SetVisible(flag)
	
		if data.isSecure == false then
			_internal.buildReBuff()

			if uiElements.buffButton ~= nil then uiElements.buffButton:SetDragable(flag) end
			if uiElements.buffButtonBar ~= nil then uiElements.buffButtonBar.subButtons[1]:SetDragable(flag) end

			if flag == false then 
				if nkRBConfig.buffButton ~= "0" then _internal.setReBuffMacro() end
				if nkRBConfig.buffButton == "always" then 
					if uiElements.buffButton ~= nil then uiElements.buffButton:SetVisible(true) end 
				else 
					if uiElements.buffButton ~= nil then uiElements.buffButton:SetVisible(false) end 
				end

				if nkRBConfig.buffButton == "bar" then 
					if uiElements.buffButtonBar ~= nil then uiElements.buffButtonBar:SetVisible(true) end
				else
					if uiElements.buffButtonBar ~= nil then uiElements.buffButtonBar:SetVisible(false) end
				end
			else
				if nkRBConfig.buffButton == "bar" then
					if uiElements.buffButtonBar ~= nil then uiElements.buffButtonBar:SetVisible(true) end
				else
					if uiElements.buffButton ~= nil then uiElements.buffButton:SetVisible(true) end
				end
			end
		end

		data.configOpen = flag
		oSetVisible(self, flag)

		if flag == true then
			_internal.displayAllIcons(true)
		else
			_internal.hideAllIcons()
			_internal.CheckMissingBuffs('player', '_ui.Config')
			_internal.CheckMissingBuffs('player.pet', '_ui.Config')
			_internal.CheckMissingBuffs('player.target', '_ui.Config')
		end
	end

	function config:GetTabPane() return tabPane end
	
	local function _fctTabChanged(_, newTab)
		if newTab == 3 then
			paneTabTrigger:UpdateSetSelect(false)
		end
	end
	
	function config:InitAnalyze(flag)
	
		if flag then
			analyzerButton:SetColor(0, 0.6, 0)
			analyzerButton:SetBorderColor(0, 0.4, 0)
		else
			analyzerButton:SetColor(EnKai.art.GetThemeColor('elementSubColor').r, EnKai.art.GetThemeColor('elementSubColor').g, EnKai.art.GetThemeColor('elementSubColor').b)
			analyzerButton:SetBorderColor(EnKai.art.GetThemeColor('elementMainColor').r, EnKai.art.GetThemeColor('elementMainColor').g, EnKai.art.GetThemeColor('elementMainColor').b)
		end
		
		analyzerButton:AnimateIcon(flag)
		
	end
	
	function config:EditIcon(thisIcon)
	
		tabPane:SwitchToPane(3)
		paneTabTrigger:EditIcon(thisIcon)
	
	end
	
	Command.Event.Attach(EnKai.events[tabPane:GetName()].TabPaneChanged, _fctTabChanged, "nkRebuff.Config.EnKai.TabPane.Changed")

	config:SetVisible(true)
	
	return config
	
end