local addonInfo, privateVars = ...

if EnKai.tools.lang.getLanguage() ~= "German" then
	
	privateVars.langTexts = {
		btClose        = "Close",
		txtVersion				= 'Version %s',
		
		msgMigrate				= "Welcome to nkRebuff Version %s!\n\nThis new version offers a lot of additional features. The existing sets need to migrated.\n\nThe existing sets might not work correctly any more. In this case you'll unfortunately have to delete an re-create a set.\n\nnkRebuff now support sub sets. You can activate a sub set through the command nkRebuff subset=<no>.",
		
		msgNewItemVersion		= 'nkRebuff: New version of <font color="#0094FF">%s</font> found. Updating config!',
		msgActivateSetInCombat  = "nkRebuff: <font color='#FF0000'>Player is in fight!</font> Set will not be changed.",
		tabHeaderSettings		= 'Settings',
		tabHeaderIconDefaults	= "Icon defaults",
		tabHeaderTracking		= 'Triggers',
		tabHeaderExchange		= 'Import/Export',
		tabHeaderManual			= 'Manual',
		manualHeader			= 'nkRebuff manual',
		
		noSubSet				= 'None active',
		
		exportButton			= 'Export set',
		importButton			= 'Import set',
		shareButton				= 'Share set',
		importErrorChecksum		= 'The import failed (checksum)! The text is not matching what was exported!',
		importErrorFormat		= 'The import failed due to an incorrect data format!',
		exportHint				= 'After doing the export please click into the field and do CTRL+A and CTRL+C. Afterwards hit ESC to leave the field.\nTo import simply paste the export code into this field and click the import button.',
		
		buffButtonHintHeader	= 'Rebuff button',
		buffButtonHintDesc		= 'Click the button to activate missing buffs. One buff will be activated per click.\n\nNext action:\n<font color="#FFD800">%s</font>',
		
		setTypeSelect			= "Edit set",
		setExportTypeSelect		= "Export set",
		setTypeSelectList		= {{ label = "Main set", value = "mainSet"}, { label = "Sub set", value = "subSet"}},
		
		targetSelectList		= {{ label = "Player", value = "player"}, { label = "Player's target", value = "player.target" }, { label = "Player's pet", value = "player.pet" }, { label = "Focus target", value = "focus" } },
		targetSelect			= "Unit",
		
		iconActive				= "Trigger active",
		replaceTrigger			= "Do you want to replace the existing trigger?",
		
		setSelect				= "Edit set",
		setExportSelect			= "Export set",
		
		headerDescription		= 'Description',
		design					= 'Design',
		showLabel				= 'Show label',
		showBorder				= 'Show border',
		showTimer				= 'Show timer',
		showStack				= 'Show stack',
		scale					= 'Scale %d%%',
		functionality			= 'Functionality',
		runOutWarning			= '%d sec warning',
		color					= 'Color',
		outline       = 'Outline',
		trackGridHint			= 'Left click to edit / right click to activate or deactivate',
		update					= 'Update',
		useDefaults				= "Use defaults",
		showIf					= "Show if",
		showIfSelection			= {{ label = "active", value = true}, { label = "inactive", value = false }},
		showIfStack				= "and no of stacks",
		showIfStackSelection	= {{ label = "<", value = "less"}, { label = "=", value = "equal" }, { label = ">", value = "greater" }, { label = "n/a", value = "na" }},
		displayLabel			= "Display definition",
		overrideLabel			= "Override the default",
		positionLabel			= "Position of the icon",
		
		showIfActiveHint		= "Icon is shown if\nDeactivated: Buff/Debuff is <font color='#FF0000'>missing</font>\nActivated: Buff/Debuff is <font color='#FF0000'>applied</font>",
		create					= 'Create',
		delete					= 'Delete',
		abilityType				= 'Type',
		duration				= 'Duration',
		durationValue			= '%d sec',
		castBy					= 'Cast by',
		storeThis				= 'Store this',
		analyze					= 'Scan',
		recorded				= 'Analyzer',
		storeSelected			= 'Store selected',
		gcd						= 'Global cooldown %1.1f sec',
		analyzeHint				= "(1) Cast ability\n(2) Left click line of ability to store => Store this cell become green\n(3) Click on button",
		shortLabels				= "Short labels",
		labelGlobal				= "Global settings",
		effect					= "icon effect",
		effectSelection			= {{ label = "- deactivated - ", value = 'none', }, { label = 'Glossy', value = 'gloss' }, { label = 'Round', value = 'round'}, { label = 'Basic', value = 'basic' }, { label = 'Chrome', value = 'chrome' },
									{ label = "Rounded corners", value = 'roundedCorners'} },
		stackHint				= "The stack color is a global setting for all icons using the default. Whether an icon displays the stack has to be set individually per icon!",
		triggerLabel			= "Trigger definition",
		iconEditHint			= "Icon definition",		
		removeAbility			= "Remove ability",
		
		colorSelection = {{label = "Black", value = 'black' }, {label = "White", value = 'white'}, { label = "Red", value = 'red'}, { label = "Yellow", value = 'yellow'}, { label = "Blue", value = 'blue'}},
		
		settingSelection = {	{ value = 'buffsPlayer', label = "Buffs on player"},  { value = 'buffsPet', label = 'buffs on pet'}, { value = 'debuffsTarget', label = "Debuffs on target"}, { value = 'cooldownsPlayer', label = "Cooldowns"} },
		selSetting 			 = 'Ability',
		
		genericSettings = {
			basic			= 'Basic settings',
			performance		= 'Performance',
			sets 			= 'Sets',
			setsHint		= 'Please first manually switch the role and then the set. Otherwise pictures\nof new abilities are not available for selection in the config!',
			
			active			= 'Addon activated',
			usePluginCheckbox	= 'Use nkPanel plugin',
			throttleSlider		= 'Update interval %.1f sec',
			roleSwitch 		= 'Recognize role swith',
			currentMainSet 		= 'Current main set',
			currentSubSet		= 'Current sub set',
			checkForUpdatesCheckbox = 'Check for updates',
			showTooltipsCheckbox	= 'Show tooltips',
			
			addButton		= 'Add',
			newSetName		= 'New set %d',
			copiedSetName	= 'Copy of %s',
			removeButton	= 'Delete',
			copySetButton	= 'Copy',
			role			= 'assigned role',
			
			cbCombat		= "Show only in combat",
			selectionRole 	= {{ label = 'deactivated', value = 0 } },
			roleLabel		= "Role %d",
			
			buffButton		= "ReBuff Button",
			showButton		= "Show button",
			bbDisplay		= {{ label = "- deactivated -", value = '0'}, { label = "always", value = "always"}, { label = "if rebuff is needed", value = "rebuff"}, { label = "show bar", value = "bar"}},
			bbHint			= "Clicking the ReBuff button you can automatically apply missing buffs.\n<font color='#FF0000'>Only works out of combat!</font>\nRight click and drag while in config to move the button on the screen."
		},
		
		messages = {
			dialogTitle			= 'Error message',
			cannotRemoveLastSet = 'You cannot delete the last set!',
			removeCurrentSet	= 'Are you sure you want to delete the set?',
			createIcons			= 'Do you want to create icons for the selected abilities?',
			importDuplicateSet	= 'A set with the name %s already exists!\nDo you want to overwrite the existing set?',
			importAsNewSet		= 'Instead, would you like to import the set under a new name?',
		},
	
		various = {
			buttonMenuConfig	= "Configuration",
			buttonMenuManual	= "Manual",
			msgLoaded			= "%s %s loaded",
			version				= "Version",
			commandSetRefuse 	= 'Invalid set! valid values are 1 - %d',
			activateMainSet		= 'Activating nkRebuff <font color="#0094FF">Main</font> set <font color="#0094FF">%s</font>',
			activateSubSet		= 'Activating nkRebuff <font color="#0094FF">Sub</font> set <font color="#0094FF">%s</font>',
		},
		
		player	= 'Player',
		pet		= 'Pet',
		npc		= 'NPC',
		debuff	= 'Debuff',
		buff	= 'Buff',
		buffOnPet = 'Buff on pet',
		cooldown= 'Cooldown',
		curse	= 'Curse',

		errTypeConfig 		= "nkRebuff Error - Configuration",
		errMissingBuffData	= "No stored info for <font color='#0094FF'>%s</font>. Please re-perform analyse."
	}
	
end