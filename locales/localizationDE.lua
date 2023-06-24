local addonInfo, privateVars = ...

if ( EnKai.tools.lang.getLanguage()  == "German") then
	
	privateVars.langTexts = {
	  btClose        = "Schliessen",
		txtVersion			= 'Version %s',
		
		msgMigrate				= 'Willkommen bei nkRebuff Version %s\n\nDie neue Version bietet viele zusätzliche Funktionen. Dazu müssen die bisherigen Sets migriert werden.\n\nEs ist möglich, dass die bisherigen Sets nicht mehr richtig funktionieren. In diesem Fall muss ein Set leider neu gebaut werden.\n\nnkRebuff kennt nun neben den Hauptsets auch Nebensets. Diese können über den Befehl nkRebuff subset=<no> aktiviert werden.',
		msgNewItemVersion		= 'nkRebuff: Neue Version von <font color="#0094FF">%s</font> gefunden. Aktualisiere Konfiguration!',
		msgActivateSetInCombat  = "nkRebuff: <font color='#FF0000'>Spieler ist im Kampf!</font> Set wird nicht gewechselt.",
		tabHeaderSettings		= 'Einstellungen',
		tabHeaderIconDefaults	= "Icon Standards",
		tabHeaderTracking		= 'Auslöser',
		tabHeaderExchange		= 'Import/Export',
		tabHeaderManual			= 'Handbuch',
		manualHeader			= 'nkRebuff Handbuch',
				
		noSubSet				= 'Keines aktiv',
				
		exportButton			= 'Exportieren',
		importButton			= 'Importieren',
		shareButton				= 'Teilen',
		importErrorChecksum		= 'Der Import ist fehlgeschlagen (Checksum)! Der Text entspricht nicht demjenigen beim Export!',
		importErrorFormat		= 'Der Import ist fehlgeschlagen da das Format inkorrekt ist!',
		exportHint				= 'Nach dem Klicken des Export Buttons bitte in das Feld klicken und per CTRL+A und CTRL+C den Inhalt kopieren. Anschliessend ESC drücken um das Feld zu verlassen.\nZum Importieren einfach den code in das Feld einfügen und den Button Import klicken.',		
		
		buffButtonHintHeader	= 'Rebuff Button',
		buffButtonHintDesc		= 'Klick den Button um fehlende Verstärkungen zu aktivieren. Pro Klick wird eine Verstärkung aktiviert.\n\nNächste Aktion:\n<font color="#FFD800">%s</font>',
		
		setTypeSelect			= "Set bearbeiten",
		setExportTypeSelect		= "Set exportieren",
		setTypeSelectList		= {{ label = "Hauptset", value = "mainSet"}, { label = "Subset", value = "subSet"}},
		
		targetSelectList		= {{ label = "Spieler", value = "player"}, { label = "Ziel des Spielers", value = "player.target" }, { label = "Begleiter", value = "player.pet" }, { label = "Fokus Ziel", value = "focus" } },
		targetSelect			= "Einheit",
		
		setSelect				= "Bearbeite Set",
		setExportSelect			= "Exportiere Set",
		
		iconActive				= "Auslöser aktiviert",
		replaceTrigger			= "Wollen Sie den bestehenden Auslöser ersetzen?",
		
		headerDescription		= 'Beschreibung',
		design					= 'Optik',
		showLabel				= 'Bezeichnung anzeigen',
		showBorder				= 'Rahmen anzeigen',
		showTimer				= 'Zähler anzeigen',
		showStack				= 'Stapel anzeigen',
		scale					= 'Skalierung %d%%',
		functionality			= 'Funktionalität',
		runOutWarning			= '%d sec Warnung',
		color					= 'Farbe',
		outline					= 'Rahmen',
		trackGridHint			= 'Links-Click zum editieren / Rechts-Click zum aktivieren & deaktivieren',
		update					= 'Aktualisieren',
		useDefaults				= "Standard verwenden",
		showIf					= "Zeige wenn",
		showIfSelection			= {{ label = "Aktiv", value = true}, { label = "Inaktiv", value = false }},
		showIfStack				= "und Anzahl Stacks",
		showIfStackSelection	= {{ label = "<", value = "less"}, { label = "=", value = "equal" }, { label = ">", value = "greater" }, { label = "n/a", value = "na" }},
		displayLabel			= "Definition der Anzeige",
		overrideLabel			= "Den Standard übersteuern",
		positionLabel			= "Position des Icons",
		
		showIfActiveHint		= "Symbol erscheint wenn\nDeaktiviert: Buff/Debuff <font color='#FF0000'>fehlt</font>\nAktiviert: Buff/Debuff ist <font color='#FF0000'>aktiv</font>",
		create					= 'Erstellen',
		delete					= 'Löschen',
		abilityType				= 'Art',
		duration				= 'Laufzeit',
		durationValue			= '%d Sek',
		castBy					= 'Gewirkt von',
		storeThis				= 'Übernehmen',
		analyze					= 'Scannen',
		recorded				= 'Analyzer',
		storeSelected			= 'Übernehmen',
		gcd						= 'Global cooldown %1.1f Sek',
		analyzeHint				= "(1) Fähigkeiten wirken\n(2) Gewünschte Zeile mit linker Maustaste anklicken => Übernehmen Spalte wird grün\n(3) Übernehmen Knopf drücken",
		shortLabels				= "Kurze Bezeichnung",
		labelGlobal				= "Globale Einstellungen",
		effect					= "Icon Effekt",		
		effectSelection			= {{ label = "- deaktiviert - ", value = 'none', }, { label = 'Glänzend', value = 'gloss' }, { label = 'Rund', value = 'round'}, { label = 'Einfach', value = 'basic' }, { label = 'Chrom', value = 'chrome' },
									{ label = "Abgerundete Ecken", value = 'roundedCorners'} },
		stackHint				= "Die Farbe des Stapels gilt global für alle Icons ohne individuelle Einstellung. Ob ein Stapel angezeigt wird, muss pro Icon definiert werden!",
		iconEditHint			= "Definition des Symbolbilds",
		triggerLabel			= "Definition des Auslösers",
		removeAbility			= "Fähigkeit entf.",
		
		colorSelection = {{label = "Schwarz", value = 'black' }, {label = "Weiss", value = 'white'}, { label = "Rot", value = 'red'}, { label = "Gelb", value = 'yellow'}, { label = "Blau", value = 'blue'}},
		
		settingSelection = {	{ value = 'buffsPlayer', label = "Verstärkungen"}, { value = 'buffsPet', label = 'Verstärkungen auf Begleiter'}, { value = 'debuffsTarget', label = "Schwächungen - Ziel"}, { value = 'cooldownsPlayer', label = "Abklingzeiten"} },
		selSetting 		 = 'Fähigkeit',
		
		genericSettings = {
			basic			= 'Grundeinstellungen',
			performance		= 'Leistung',
			sets 			= 'Sets',
			setsHint		= 'Bitte erst manuell die Rolle wechseln und dann das Set wählen. Andernfalls\nstehen Bilder neuer Fähigkeiten dieser Rolle nicht zur Verfügung! ',
			
			active			= 'Addon aktiviert',
			usePluginCheckbox	= 'nkPanel Plugin verwenden',
			throttleSlider		= 'Update Interval %.1f Sek.',
			roleSwitch 		= 'Rollenwechsel erkennen',
			currentMainSet 		= 'Aktives Haupt Set',
			currentSubSet		= 'Aktives Sub Set',
			checkForUpdatesCheckbox = 'Auf Updates prüfen',
			showTooltipsCheckbox	= 'Tooltips zeigen',
			
			addButton		= 'Hinzufügen',
			newSetName		= 'Neues Set %d',
			copiedSetName	= 'Kopie von %s',
			removeButton	= 'Löschen',
			copySetButton	= 'Kopieren',
			role			= 'Zugeordnete Rolle',
			
			cbCombat		= "Nur im Kampf anzeigen",
			selectionRole 	= {{ label = 'deaktiviert', value = 0 } },
			roleLabel		= "Rolle %d",
			
			buffButton		= "ReBuff Button",
			showButton		= "Button anzeigen",
			bbDisplay		= {{ label = "- deaktiviert -", value = '0'}, { label = "immer", value = "always"}, { label = "wenn Rebuff notwendig", value = "rebuff"}, { label = "als Leiste", value = "bar"}},
			bbHint			= "Mit Hilfe des ReBuff Buttons können fehlende Buffs automatisch nachgebufft\nwerden. <font color='#FF0000'>Funktioniert nur ausserhalb vom Kampf!</font>\nMit rechter Mausetaste und ziehen kann der Knopf an die gewünschte Position\nverschoben werden (Konfiguration muss geöffnet sein)."
	},
		
		messages = {
			dialogTitle			= 'Fehlermeldung',
			cannotRemoveLastSet = 'Sie können das letzte Set nicht löschen!',
			removeCurrentSet	= 'Wollen Sie das aktuelle Set wirklich löschen?',		
			createIcons			= 'Sollen für die gewählten Fähigkeiten Icons erstellt werden?',
			importDuplicateSet	= 'Es besteht schon ein Set mit dem Namen %s!\nWollen Sie das bestehende Set überschreiben?',
			importAsNewSet		= 'Wollen Sie das Set stattdessen unter einem neuen Namen importieren?',
		},
	
		various = {
			buttonMenuConfig	= "Konfiguration",
			buttonMenuManual	= "Handbuch",
			msgLoaded			= "%s %s geladen",
			version				= "Version",
			commandSetRefuse 	= 'Ungültiges Set! Gültige Werte sind 1 - %d',			
			activateMainSet		= 'Aktivere nkRebuf <font color="#0094FF">Haupt</font> Set <font color="#0094FF">%s</font>',
			activateSubSet		= 'Aktivere nkRebuf <font color="#0094FF">Sub</font> Set <font color="#0094FF">%s</font>',
		},
		
		player	= 'Spieler',
		pet		= 'Gefährte',
		npc		= 'NSC',
		debuff	= 'Schwächung',
		buff	= 'Stärkung',
		buffOnPet = 'Begleiter',
		cooldown= 'Abklingzeit',
		curse	= 'Fluch',	
		
		errTypeConfig 		= "nkRebuff Fehler - Konfiguration",
		errMissingBuffData	= "Keine Informationen zu <font color='#0094FF'>%s</font>. Bitte führen Sie die Analyse neu aus."
		
	}
	
end