Class {
	#name : 'TonelLoader',
	#superclass : 'Object',
	#instVars : [
		'settings',
		'reader',
		'applications',
		'subApplications',
		'configurationMaps',
		'loadedApplications',
		'loadedConfigurationMaps'
	],
	#classVars : [
		'DefaultAppNameSuffix',
		'CompilerWarningLevel',
		'AppSuperGroupSetting'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'instance creation' }
TonelLoader class >> new [

	^super new initialize
]

{ #category : 'instance creation' }
TonelLoader class >> on: aTonelReader [

	"Creates a new instance of receiver usin aTonelReader as its reader."
	
	^self new setReader: aTonelReader
]

{ #category : 'instance creation' }
TonelLoader class >> readFromPath: aCfsPath [

		
	^(TonelReader new readFrom: aCfsPath) createLoader
]

{ #category : 'Accessing' }
TonelLoader class >> settings [

	^TonelLoaderSettings default
]

{ #category : 'strategies-convenience' }
TonelLoader >> alwaysCreateEditions [

	^self versionStrategy alwaysCreateEditions
]

{ #category : 'lookup' }
TonelLoader >> applicationNamed: aString [
	"Returns the application with name aString or raise an error if not found."

	^self applications detect: [:one | one name asSymbol = aString asSymbol]
]

{ #category : 'lookup' }
TonelLoader >> applicationNamed: aString ifNone: aBlock [

	^self applications detect: [:one | one name = aString] ifNone: aBlock
]

{ #category : 'accessing' }
TonelLoader >> applications [

	applications ifNil: [self initializeApplications].
	^applications
]

{ #category : 'strategies' }
TonelLoader >> baseEditionStrategy [
	^self settings baseEditionStrategy
]

{ #category : 'strategies' }
TonelLoader >> baseEditionStrategy: anObject [
	self settings baseEditionStrategy: anObject
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoader >> basicLoadApplication: aTonelApplication [

	aTonelApplication prerequisites do: [:prereq |
		((self applications anySatisfy: [:any | any name asSymbol = prereq name])
			and: [self loadedApplications noneSatisfy: [:each | each name asSymbol = prereq name]])
				ifTrue: [self basicLoadApplication: (self applicationNamed: prereq name)]].
	(self loadedApplications includes: aTonelApplication)
		ifFalse: [(TonelApplicationLoader on: aTonelApplication in: self) load]
]

{ #category : 'strategies-convenience' }
TonelLoader >> beInteractive [
	self useInteractivePreqrequistesSelection.
	self useInteractiveBaseEditionSelection.
	self useInteractiveVersioning
]

{ #category : 'strategies-convenience' }
TonelLoader >> beUnattended [
	self useComputedPrerequisites.
	self useLatestBaseEditions.
	self doNotCreateVersions
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoader >> checkRepositoryContents [
	self applications isEmpty 
		ifTrue: 
			[self error: 'The selected directory does not contain any Tonel Package']
]

{ #category : 'lookup' }
TonelLoader >> configurationMapNamed: aString versionName: versionName ifNone: aBlock [

	^self configurationMaps detect: [:one | one name = aString and: [one versionName = versionName]] ifNone: aBlock
]

{ #category : 'accessing' }
TonelLoader >> configurationMaps [

	configurationMaps ifNil: [self initializeConfigurationMaps].
	^configurationMaps
]

{ #category : 'interacting' }
TonelLoader >> confirm: aString [


	^true
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoader >> createReaderForRepository: directoryPath [

	self setReader: (TonelReader new).
	self reader readFrom: directoryPath.
]

{ #category : 'strategies-convenience' }
TonelLoader >> doNotCreateVersions [
	self versionStrategy: (TonelLoaderNoVersionStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> forceCreationOfEditions [
	
	self versionStrategy alwaysCreateEditions: true
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoader >> initialize [
	super initialize.
	self beInteractive.
	self useDefaultNaming
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoader >> initializeApplications [
	"Initializes receiver applications ensuring each application initializes its subapplications deeply."

	applications := (reader packages select: [:each | each parent isNil]) 
				collect: [:each | TonelLoaderApplication on: each in: self].
	applications do: [:each | each initializeSubApplicationsWithRoot: each]
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoader >> initializeConfigurationMaps [

	configurationMaps := (reader configurationMaps
		collect: [:each | TonelConfigurationMap from: each in: self])
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoader >> load [
	"Private - Loads all the applications in the reader.
	 NOTE: The reader sorts the packages in alphabetical order, so if there is any dependency 
	 between them, it might fail."

	self loadApplications: self applications
]

{ #category : 'loading' }
TonelLoader >> loadAllApplications [
	
	^self loadApplications: self applications
]

{ #category : 'loading' }
TonelLoader >> loadAllMapsWithRequiredMaps [
	
	self configurationMaps do: [:each | each loadWithRequiredMaps ]
]

{ #category : 'loading' }
TonelLoader >> loadApplication: aTonelApplication [

	| emApps |
	emApps := (self loadApplications: (Array with: aTonelApplication)).
	^emApps isEmpty 
		ifFalse: [ emApps first]
	
]

{ #category : 'loading' }
TonelLoader >> loadApplicationForPackageNamed: aString [
	"Load the applications whose package name matches aString."

	^self loadApplication: (self applications detect: [:one | one packageName = aString])
]

{ #category : 'loading' }
TonelLoader >> loadApplicationNamed: aStringOrSymbol [

	^self loadApplication: (self applicationNamed: aStringOrSymbol)
]

{ #category : 'loading' }
TonelLoader >> loadApplications: aCollection [

	| confirmer oldWarningLevel |

	confirmer := System image confirmer: self.
	oldWarningLevel := EsCompiler defaultWarningLevel.
	EsCompiler defaultWarningLevel: self settings compilerWarningLevel.
	[aCollection do: [:each | self basicLoadApplication: each]] ensure: [
		System image confirmer: confirmer.
		EsCompiler defaultWarningLevel: oldWarningLevel].
	^aCollection collect: [:each | each emApplication]
]

{ #category : 'loading' }
TonelLoader >> loadApplicationsForPackagesNamed: aCollection [
	"Loads the applications whose package name matches the names in aCollection."
	
	^self loadApplications: (aCollection collect: [:each | self applications detect: [:one | one packageName = each]])
]

{ #category : 'loading' }
TonelLoader >> loadApplicationsNamed: aCollection [

	^self loadApplications: (aCollection collect: [:each | self applicationNamed: each])
]

{ #category : 'interacting' }
TonelLoader >> loadBaseEditionFor: aTonelApplication [

	^self baseEditionStrategy loadBaseEditionFor: aTonelApplication
]

{ #category : 'loading' }
TonelLoader >> loadConfigurationMapNamed: aString [
	
	self loadConfigurationMapNamed: aString withPrereqs: true
]

{ #category : 'loading' }
TonelLoader >> loadConfigurationMapNamed: aString withPrereqs: aBoolean [

	(self configurationMaps detect: [:one | one name = aString]) ifNotNil: [:configMap |
		aBoolean ifTrue: [configMap loadWithRequiredMaps] ifFalse: [configMap load].
		self loadedConfigurationMaps add: configMap]
]

{ #category : 'accessing' }
TonelLoader >> loadedApplications [

	^loadedApplications ifNil: [loadedApplications := Set new]
]

{ #category : 'accessing' }
TonelLoader >> loadedApplicationsIdentifiers [

	^self loadedApplications collect: [:each | each name ]
]

{ #category : 'accessing' }
TonelLoader >> loadedConfigurationMaps [

	^loadedConfigurationMaps ifNil: [loadedConfigurationMaps := Set new]
]

{ #category : 'logging' }
TonelLoader >> log: aString [

	self class owningImage logApplicationNotice: aString.
]

{ #category : 'strategies' }
TonelLoader >> namingStrategy [
	^self settings namingStrategy
]

{ #category : 'strategies' }
TonelLoader >> namingStrategy: anObject [
	self settings namingStrategy: anObject
]

{ #category : 'accessing' }
TonelLoader >> packageNames [
	
	^self reader packages collect: [:each | each name asString ]
]

{ #category : 'resolving' }
TonelLoader >> prerequisitesFor: aTonelLoaderApplication current: anOrderedCollection [


	^self prerequisitesStrategy prerequisitesFor: aTonelLoaderApplication current: anOrderedCollection 
]

{ #category : 'strategies' }
TonelLoader >> prerequisitesStrategy [
	^self settings prerequisitesStrategy
]

{ #category : 'strategies' }
TonelLoader >> prerequisitesStrategy: anObject [
	self settings prerequisitesStrategy: anObject
]

{ #category : 'interacting' }
TonelLoader >> proceed: aString [


	^true
]

{ #category : 'accessing' }
TonelLoader >> reader [
	"Returns the TonelReader of receiver."
	
	^reader
]

{ #category : 'accessing' }
TonelLoader >> repositoryPath [

	^self reader repositoryPath
]

{ #category : 'accessing' }
TonelLoader >> reset [

	loadedApplications := loadedConfigurationMaps := nil
]

{ #category : 'accessing' }
TonelLoader >> rootApplicationOfClass: aTonelReaderClassDefinition [

	self applications do: [:tonelApp |
		(tonelApp allDefinedClasses
			anySatisfy: [:tonelClass | tonelClass = aTonelReaderClassDefinition])
				ifTrue: [^tonelApp rootTonelApplication]].
	^nil
]

{ #category : 'accessing' }
TonelLoader >> rootApplicationOfClassExtension: aTonelReaderClassExtensionDefinition [

	self applications do: [:tonelApp |
		(tonelApp allDefinedClasses
			anySatisfy: [:tonelClass | tonelClass identifier = aTonelReaderClassExtensionDefinition identifier])
				ifTrue: [^tonelApp rootTonelApplication]].
	^nil
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoader >> setReader: aTonelReader [

	"Assigns aTonelReader as receiver's reader."
	
	reader := aTonelReader
]

{ #category : 'accessing' }
TonelLoader >> settings [
	^settings ifNil: [
		settings := self class settings copyFor: self.
		]
]

{ #category : 'accessing' }
TonelLoader >> settings: anObject [
	settings := anObject
]

{ #category : 'lookup' }
TonelLoader >> subApplicationNamed: aString [

	^self subApplications
		detect: [:one | one name = aString]
		ifNone: [| subAppPackage |
			subAppPackage := reader lookupPackageNamed: aString.
			self subApplications add: (TonelLoaderSubApplication on: subAppPackage in: self)]
]

{ #category : 'accessing' }
TonelLoader >> subApplications [

	^subApplications ifNil: [subApplications := OrderedCollection new]
	
]

{ #category : 'lookup',
  #vaVisibility : 'private' }
TonelLoader >> subApplicationsFor: aTonelLoaderSubApplication [
	"Returns the collection of subapplications of aTonelLoaderSubApplication."

	^(self reader packages
		select: [:each | each parent = aTonelLoaderSubApplication packageDefinition name])
			collect: [:each | self subApplicationNamed: each name]
]

{ #category : 'accessing' }
TonelLoader >> systemLoadedApplications [

	^System loadedApplications
]

{ #category : 'accessing' }
TonelLoader >> tonelClassNamed: aSymbol [

	self applications do: [:tonelApp |
		(tonelApp allDefinedClasses
			detect: [:tonelClass | tonelClass identifier = aSymbol]
			ifNone: [])
				ifNotNil: [:foundClass | ^foundClass]].
	^nil
]

{ #category : 'strategies-convenience' }
TonelLoader >> useComputedPrerequisites [
	self prerequisitesStrategy: (TonelLoaderComputedPrerequisitesStrategy for: self)
]

{ #category : 'initializing' }
TonelLoader >> useDefaultNaming [
	self namingStrategy: (TonelLoaderDefaultNamingStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> useGitVersion [
	self versionStrategy: (TonelLoaderGitVersionStrategy for: self).
	self baseEditionStrategy: (TonelLoaderGitParentBaseEditionStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> useInteractiveBaseEditionSelection [
	self 
		baseEditionStrategy: (TonelLoaderInteractiveBaseEditionStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> useInteractivePreqrequistesSelection [
	self 
		prerequisitesStrategy: (TonelLoaderInteractivePrereqStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> useInteractiveVersioning [
	self versionStrategy: (TonelLoaderInteractiveVersionStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> useLatestBaseEditions [
	self baseEditionStrategy: (TonelLoaderLatestBaseEditionStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> useSpecifiedVersion: versionName [
	self versionStrategy: ((TonelLoaderSpecifiedVersionStrategy for: self) versionName: versionName)
]

{ #category : 'resolving' }
TonelLoader >> versionFor: anObject [

	^self versionStrategy versionFor: anObject
]

{ #category : 'strategies' }
TonelLoader >> versionStrategy [

	^self settings versionStrategy
]

{ #category : 'strategies' }
TonelLoader >> versionStrategy: anObject [

	self settings versionStrategy: anObject
]
