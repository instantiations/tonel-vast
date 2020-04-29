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
		add: #loadTonelRepository
		label: TonelMsg01 "$NLS$ Import Applications from Tonel packages..."
		enable: [true]
		for: TonelTools
		after: #importSubApplications.
	importExportSubmenu subMenu
		add: #exportTonelApplication
		label:  TonelMsg02 "$NLS$ Export Applications as Tonel packages..."
		enable: [true]
		for: TonelTools
		before:  #exportApplicationVersions


]

{ #category : 'operations' }
TonelTools class >> exportTonelApplication [

	| selectedApps repositoryPath convertPools |

	selectedApps :=
		CwListSelectionPrompter new
			title: TonelMsg27 "$NLS$ Select applications to export in Tonel format";
			messageString: TonelMsg28 "$NLS$ Select which applications you want to export in Tonel format to a specific";
			labelString: TonelMsg29 "$NLS$ Available applications";
			selectedLabelString: TonelMsg30 "$NLS$ Applications to be exported";
			items: (System loadedApplications asSortedCollection: Class sortBlock);
			selectedItems: #();
			selectionPolicy: CwConstants::XmEXTENDEDSELECT;
			printBlock: [:app | app name];
			selectedPrintBlock: [:app | app name];
			prompt.
	selectedApps isEmptyOrNil ifTrue: [^self].

	(EtFileNamePrompter
		promptForFileName: TonelMsg31 "$NLS$ Select target path"
		default: '.project' "$NON-NLS$"
		at: System cursorPosition
		save: true)
			ifNil: [^self]
			ifNotNil: [:string | repositoryPath := (CfsPath named: string) directory].

	convertPools := (System confirm: ('Do you want to convert SharedPool declarations?', Character cr asString, '(Select NO if you are not going to load the exported class in another Smalltalk dialect)')).

	TonelWriter new
		applications: selectedApps;
		convertsSharedPools: convertPools;
		writeProjectInto: repositoryPath




]

{ #category : 'operations' }
TonelTools class >> exportTonelTools [

	TonelWriter new
		addLatestConfigurationMapNamed: 'Tonel';
		addLatestConfigurationMapNamed: 'Test Tonel';
		addApplicationsFromConfigurationMaps;
		writeProjectInto: ((CfsPath named: CfsDirectoryDescriptor getcwd) append: '..\tonel-repos\tonel-vast').

]

{ #category : 'operations' }
TonelTools class >> loadTonelRepository [
	"Enter the new method definition below and click 'Resume'."

	| reader loader repositoryPath selectedApps versionStrategyClass |

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
	loader := TonelLoader on: reader.
	selectedApps :=
		CwListSelectionPrompter new
			title: TonelMsg15 "$NLS$ Select Tonel Packages to be imported as VAST Applications";
			messageString: TonelMsg21 "$NLS$ The following Tonel Packages will be imported as VAST Applications";
			labelString: TonelMsg22 "$NLS$ Available Tonel Packages";
			selectedLabelString: TonelMsg23 "$NLS$ Selected Tonel Packages";
			items: (loader applications asSortedCollection: [:a :b | a name <= b name]);
			selectedItems: #();
			selectionPolicy: CwConstants::XmEXTENDEDSELECT;
			printBlock: [:app | app name];
			selectedPrintBlock: [:app | app name];
			prompt.

	selectedApps isEmptyOrNil ifTrue: [^self].

	loader applications isEmpty
		ifTrue: [
			self halt: TonelMsg25 "$NLS$ The selected Tonel repository is not valid or does not contain any package.'.".
			^self].
			
	versionStrategyClass :=
		CwListPrompter new
			title: 'Select the versioning strategy';
			messageString: 'Select how you want to version the Applications and classes loaded';
			labelString: 'Available versioning strategies';
			items: (TonelLoaderVersionStrategy allSubclasses);
			selectedItems: (Array with: TonelLoaderInteractiveVersionStrategy);
			selectionPolicy: CwConstants::XmSINGLESELECT;
			printBlock: [:app | app description];
			prompt. 
	
	versionStrategyClass ifNil: [	^self].
	
	loader versionStrategy: (versionStrategyClass for: loader).
	loader versionStrategy isSpecific ifTrue: [
		| versionName |
		versionName := (CwTextPrompter
		prompt: 'Enter the version name you want to use for the loaded components'
		answer: ''
		title: 'Enter version name').
		versionName isEmpty 
			ifTrue: [^self]
			ifFalse: [loader versionStrategy versionName: versionName]
	].
	
	((CwMessagePrompter new)
				iconType: CwConstants::XmICONQUESTION;
				title: 'Confirm the forced creation of editions';
				buttonType: CwConstants::XmYESNOCANCEL;
				messageString: 'Do you want to create editions even for Applications and classes without changes?';
				prompt) ifNil: [^self]
				ifNotNil: [:answer |
					loader versionStrategy alwaysCreateEditions: answer
				].
	
	
	loader loadApplications: selectedApps


]
