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

	| selectedApps repositoryPath |
	 selectedApps := CwListSelectionPrompter new
			title: TonelMsg27 "$NLS$ Select applications to export in Tonel format";
			messageString: TonelMsg28 "$NLS$ Select which applications you want to export in Tonel format to a specific";
			labelString: TonelMsg29 "$NLS$ Available applications";
			selectedLabelString: TonelMsg30 "$NLS$ Applications to be exported";
			items: (System loadedApplications asSortedCollection: Class sortBlock);
			selectedItems: #();
			selectionPolicy: CwConstants::XmEXTENDEDSELECT;
			printBlock: [:app | app name];
			selectedPrintBlock: [:app |  app name];
			prompt.
	selectedApps isEmptyOrNil ifTrue: [^self].
	
	(EtFileNamePrompter
		promptForFileName: TonelMsg31 "$NLS$ Select target path"
		default: '.project' "$NON-NLS$"
		at: System cursorPosition
		save: true)
			ifNil: [^self]
			ifNotNil: [:string |
			repositoryPath :=(CfsPath named: string) directory].
		
	TonelWriter new
		writeProjectIncluding: selectedApps
		into: repositoryPath .
	
	

	
]

{ #category : 'operations' }
TonelTools class >> exportTonelTools [

	TonelWriter new
		writeProjectIncluding: (#(TonelBaseApp TonelFileSystem TonelLoaderModel TonelLoaderTests TonelReaderModel TonelReaderTests TonelTools TonelWriterModel TonelWriterTests) collect: [:symbol | Smalltalk at: symbol])  
		into: ((CfsPath named: CfsDirectoryDescriptor getcwd) append: '../tonel-vast').

]

{ #category : 'operations' }
TonelTools class >> loadTonelRepository [
	"Enter the new method definition below and click 'Resume'."

	| reader loader repositoryPath selectedApps |

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

	reader readPackagesFrom: repositoryPath.
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

	loader loadApplications: selectedApps


]
