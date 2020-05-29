Class {
	#name : 'TonelTools',
	#superclass : 'Application',
	#category : 'TonelTools'
}

{ #category : 'ENVY Menu Extensions' }
TonelTools class >> addToApplicationsMenu: aMenu browser: aBrowser [
	"There are several browsers with an Applications menu item, but only the Application Manager
	 browser supports importing.  Add a new item to the Import... or Import/Export... submenu."

	| importExportSubmenu |

	importExportSubmenu := aMenu menuItemWithValue: #importSubMenu. "EtApplicationManager"
	importExportSubmenu ifNil: [
		importExportSubmenu := aMenu menuItemWithValue: #applicationsImportExportSubMenu. "StsApplicationManager"
		importExportSubmenu ifNil: [^self]].
	importExportSubmenu subMenu
		add: #loadTonelApplications
		label: TonelMsg01 "$NLS$ Import Applications from Tonel packages..."
		enable: [true]
		for: TonelTools
		after: #importSubApplications.
	importExportSubmenu subMenu
		add: #exportTonelApplications
		label:  TonelMsg02 "$NLS$ Export Applications as Tonel packages..."
		enable: [true]
		for: nil
		before:  #exportApplicationVersions


]

{ #category : 'ENVY Menu Extensions' }
TonelTools class >> addToNamesMenu: aMenu browser: aBrowser [


	(aMenu menuItemWithValue: #importSubMenu) ifNotNil: [:menu |
		menu subMenu
			add: #loadTonelConfigMaps
			label: 'Load Configuration Maps from Tonel repository...'
			enable: [true]
			for: TonelTools
			after: #importMostRecentConfigMaps.

		menu subMenu addLineBefore: #stsToggleImportSource.
		
		].
		
		(aMenu menuItemWithValue: #exportSubMenu) ifNotNil: [:menu |
		menu subMenu
			add: #exportTonelConfigMaps
			label: 'Export Configuration Maps to Tonel '
			enable: [true]
			for: nil
			after: #exportMostRecentConfigMaps.
		menu subMenu addLineAfter: #exportTonelConfigMaps
	]
]

{ #category : 'operations' }
TonelTools class >> exportConfigurationMapsNames: anOrderedCollection [

	| configurationMaps repositoryPath |

	configurationMaps := self promptConfigurationMapsVersionsFrom: anOrderedCollection.
	configurationMaps ifNil: [^self].
	(configurationMaps collect: [:each | each name]) asSet size < configurationMaps size
		ifTrue: [
			(System confirm:
				'You have selected more than one version for the same Configuration Map. Only the most recent one will be exported. Do you want to continue?')
					ifFalse: [^self]].

	(configurationMaps allSatisfy: [:each | each isLoaded])
		ifFalse: [
			(System confirm:
				'You have selected Configuration Maps that are not loaded, they will be loaded with their required maps before exporting. Do you want to continue?')
					ifFalse: [^self]].

	self promptRepositoryPath
		ifNil: [^self]
		ifNotNil: [:string | repositoryPath := (CfsPath named: string) directory].
	(TonelWriter new)
		addConfigurationMaps: configurationMaps;
		addApplicationsFromConfigurationMaps;
		writeProjectInto: repositoryPath
]

{ #category : 'operations' }
TonelTools class >> exportTonelApplications: aCollection [

	| selectedApps repositoryPath clearSources |
	selectedApps := (CwListSelectionPrompter new)
				title: TonelMsg27;
				messageString: TonelMsg28;
				labelString: TonelMsg29;
				selectedLabelString: TonelMsg30;
				items: (System loadedApplications asSortedCollection: Class sortBlock);
				selectedItems: aCollection;
				selectionPolicy: CwConstants::XmEXTENDEDSELECT;
				printBlock: [:app | app name];
				selectedPrintBlock: [:app | app name];
				prompt.	"$NLS$ Select applications to export in Tonel format"	"$NLS$ Select which applications you want to export in Tonel format to a specific"	"$NLS$ Available applications"	"$NLS$ Applications to be exported"
	selectedApps isEmptyOrNil ifTrue: [^self].
	(EtFileNamePrompter 
		promptForFileName: TonelMsg31
		default: '.project'
		at: System cursorPosition
		save: true) ifNil: [^self]
			ifNotNil: [:string | repositoryPath := (CfsPath named: string) directory].	"$NLS$ Select target path"	"$NON-NLS$"
	
	clearSources := self promptClearSources.
	(TonelWriter new)
		applications: selectedApps;
		clearsSourcesDirectory: clearSources;
		writeProjectInto: repositoryPath
]

{ #category : 'convenience',
  #vaVisibility : 'private' }
TonelTools class >> exportTonelTools [

	TonelWriter new
		addLatestConfigurationMapNamed: 'Tonel';
		addLatestConfigurationMapNamed: 'Test Tonel';
		addApplicationsFromConfigurationMaps;
		writeProjectInto: ((CfsPath named: CfsDirectoryDescriptor getcwd) append: '..\tonel-repos\tonel-vast').

]

{ #category : 'operations' }
TonelTools class >> loadTonelApplications [
	"Enter the new method definition below and click 'Resume'."

	| reader loader repositoryPath selectedApps |
	(EtFileNamePrompter 
		promptForFileName: TonelMsg12
		default: '.project'
		at: System cursorPosition) ifNil: [^self]
			ifNotNil: [:string | repositoryPath := (CfsPath named: string) directory].	"$NLS$ Select Tonel repository path"
	reader := TonelReader new.
	(repositoryPath exists 
		and: [(reader computeSourcesDirectoryFrom: repositoryPath) exists]) 
			ifFalse: 
				[self halt: TonelMsg14.	"$NLS$ The selected Tonel repository does not contain a valid sources directory."
				^self].
	reader readFrom: repositoryPath.
	loader := TonelLoader on: reader.
	selectedApps := (CwListSelectionPrompter new)
				title: TonelMsg15;
				messageString: TonelMsg21;
				labelString: TonelMsg22;
				selectedLabelString: TonelMsg23;
				items: (loader applications asSortedCollection: [:a :b | a name <= b name]);
				selectedItems: #();
				selectionPolicy: CwConstants::XmEXTENDEDSELECT;
				printBlock: [:app | app name];
				selectedPrintBlock: [:app | app name];
				prompt.	"$NLS$ Select Tonel Packages to be imported as VAST Applications"	"$NLS$ The following Tonel Packages will be imported as VAST Applications"	"$NLS$ Available Tonel Packages"	"$NLS$ Selected Tonel Packages"
	selectedApps isEmptyOrNil ifTrue: [^self].
	loader applications isEmpty 
		ifTrue: 
			[self halt: TonelMsg25.	"$NLS$ The selected Tonel repository is not valid or does not contain any package.'."
			^self].

	"If the default version strategy is not git, we check whether the files are in a git repository to enable git versioning by default."
	self setVersionStrategyOf: loader.
	(loader loadApplications: selectedApps) notEmpty ifTrue: [
		System image message: 'Load of Tonel Applications completed.'
	]
]

{ #category : 'operations' }
TonelTools class >> loadTonelConfigMaps [

	| reader loader repositoryPath selectedMaps versionStrategyClass |

	(EtFileNamePrompter
		promptForFileName: TonelMsg12 "$NLS$ Select Tonel repository path"
		default: '.project'
		at: System cursorPosition)
			ifNil: [^self]
			ifNotNil: [:string | repositoryPath := (CfsPath named: string) directory].
	reader := TonelReader new.
	(repositoryPath exists and: [(reader computeSourcesDirectoryFrom: repositoryPath) exists])
		ifFalse: [
			self halt: TonelMsg14 "$NLS$ The selected Tonel repository does not contain a valid sources directory.".
			^self].

	reader readFrom: repositoryPath.
	loader := reader createLoader.
	selectedMaps :=
		CwListSelectionPrompter new
			title: 'Select Configuration Maps to be loaded.';
			messageString:
				'The following ConfigurationMaps will be imported and loaded with all its applications and required maps';
			labelString: 'Configuration Maps in this repository';
			selectedLabelString: 'Selected Configuration Maps';
			items: (loader configurationMaps asSortedCollection: [:a :b | a name <= b name]);
			selectedItems: #();
			selectionPolicy: CwConstants::XmEXTENDEDSELECT;
			printBlock: [:app | app name , ' ' , app versionName];
			selectedPrintBlock: [:app | app name];
			prompt.

	selectedMaps isEmptyOrNil ifTrue: [^self].

	loader configurationMaps isEmpty
		ifTrue: [
			self halt:
				'The selected Tonel repository is not valid or does not contain any configuration map.'.
			^self].

	self setVersionStrategyOf: loader.
	loader loadConfigurationMaps: selectedMaps


]

{ #category : 'prompting',
  #vaVisibility : 'private' }
TonelTools class >> promptApplications [
	^(CwListSelectionPrompter new)
		title: TonelMsg27;
		messageString: TonelMsg28;
		labelString: TonelMsg29;
		selectedLabelString: TonelMsg30;
		items: (System loadedApplications asSortedCollection: Class sortBlock);
		selectedItems: #();
		selectionPolicy: CwConstants::XmEXTENDEDSELECT;
		printBlock: [:app | app name];
		selectedPrintBlock: [:app | app name];
		prompt
]

{ #category : 'prompting',
  #vaVisibility : 'private' }
TonelTools class >> promptClearSources [
	^System 
		confirm: 'Do you want to delete the contents of the sources directory before exporting?' 
				, Character cr asString 
					, '(Select NO if you want to preserve other packages that might be in the same directory)'
]

{ #category : 'prompting',
  #vaVisibility : 'private' }
TonelTools class >> promptConfigurationMapsVersionsFrom: anOrderedCollection [

	^(CwDoubleListSelectionPrompter new)
		selectionPolicy: XmEXTENDEDSELECT;
		dependentSelectionPolicy: XmSINGLESELECT;
		messageString:
			'Select the Configuration Maps you want to export (only loaded maps can be exported)';
		items: anOrderedCollection;
		labelString: 'Configuration Maps';
		dependentListBlock: [:mapName | (EmConfigurationMap editionsFor: mapName) asArray];
		dependentLabelString: 'Versions';
		dependentPrintBlock: [:map |
			map isLoaded ifTrue: [map signature , ' [LOADED]'] ifFalse: [map signature]];
		selectedLabelString: 'Configuration maps';
		selectedPrintBlock: [:map | map signature];
		prompt
]

{ #category : 'prompting',
  #vaVisibility : 'private' }
TonelTools class >> promptForcedCreationOfEditions [
	^(CwMessagePrompter new)
		iconType: CwConstants::XmICONQUESTION;
		title: 'Confirm the forced creation of editions';
		buttonType: CwConstants::XmYESNOCANCEL;
		messageString: 'Do you want to create editions even for Applications and classes without changes?';
		prompt
]

{ #category : 'prompting',
  #vaVisibility : 'private' }
TonelTools class >> promptPoolConversion [
	^System 
		confirm: 'Do you want to convert SharedPool declarations?' 
				, Character cr asString 
					, '(Select NO if you are not going to load the exported class in another Smalltalk dialect)'
]

{ #category : 'prompting',
  #vaVisibility : 'private' }
TonelTools class >> promptRepositoryPath [
	^EtFileNamePrompter 
		promptForFileName: TonelMsg31
		default: '.project'
		at: System cursorPosition
		save: true	"$NLS$ Select target path"	"$NON-NLS$"
]

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelTools class >> setVersionStrategyOf: loader [

	loader versionStrategy class isGit 
		ifFalse: 
			[([(TonelLoaderGitVersionStrategy for: loader) attemptVersionFromGit] 
				on: TonelLoaderError
				do: [:ex | ex return]) ifNotNil: [loader useGitVersion]]	"If the default version strategy is not git, we check whether the files are in a git repository to enable git versioning by default."
]
