Class {
	#name : 'TonelLoader',
	#superclass : 'Object',
	#instVars : [
		'reader',
		'applications',
		'subApplications',
		'configurationMaps',
		'baseEditionStrategy',
		'versionStrategy',
		'prerequisitesStrategy',
		'loadedApplications',
		'loadedConfigurationMaps'
	],
	#classVars : [
		'CompilerWarningLevel',
		'AppSuperGroupSetting',
		'AppNameSuffix'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Accessing' }
TonelLoader class >> appNameSuffix [
	"Read comment of appNameSuffix:"

	^ AppNameSuffix ifNil: [ AppNameSuffix := self defaultAppNameSuffix ]
]

{ #category : 'Accessing' }
TonelLoader class >> appNameSuffix: rootAppSuffix [
	"Allows the user to specify the suffix to be used for the created root application
	by the MetacelloImporter. The default will be 'App'. 

	Arguments:
		rootAppSuffix - <String> The root application name suffix. 
	 "
	
	AppNameSuffix := rootAppSuffix
]

{ #category : 'Accessing' }
TonelLoader class >> appSuperGroupSetting [
	"Read comment of appSuperGroupSetting:"
	
	^ AppSuperGroupSetting ifNil: [ AppSuperGroupSetting := self defaultAppSuperGroupSetting ]
]

{ #category : 'Accessing' }
TonelLoader class >> appSuperGroupSetting: superGroup [
	"Allows the user to specify the 'Super Group' setting to be used for the created applications and subapplications
	by the MetacelloImporter. The default will be #none. 

	Arguments:
		superGroup - <Symbol> Possible values are #none, #world and #group.
	 "
	AppSuperGroupSetting := superGroup
]

{ #category : 'Accessing' }
TonelLoader class >> compilerWarningLevel [
	 "Read comment of compilerWarningLevel:"
	 
	^ CompilerWarningLevel ifNil: [ CompilerWarningLevel := self defaultCompilerWarningLevel ]
]

{ #category : 'Accessing' }
TonelLoader class >> compilerWarningLevel: aLevel [
	"Allows the user to specify the compiler warning level used while MonticelloImporter compiles 
	 the new methods. When we are importing code, we want to get our code in VA as soon as possible.
	 Therefore, the default is the less restrictive level (level 0) rather than the current one. Once the
	 import finishes, the warning is rollbacked to the previous level. For mode details, read comment in
	 EsCompiler >>#defaultWarningLevel.
	 
	Arguments:
		aLevel - <Number> Possible values are from 0 to 3. 
	 "
	CompilerWarningLevel := aLevel
]

{ #category : 'Accessing - Defaults' }
TonelLoader class >> defaultAppNameSuffix [
	
	^ 'App'
]

{ #category : 'Accessing - Defaults' }
TonelLoader class >> defaultAppSuperGroupSetting [
	
	^ #none
]

{ #category : 'Accessing - Defaults' }
TonelLoader class >> defaultCompilerWarningLevel [
	
	^ 0
]

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
	^baseEditionStrategy
]

{ #category : 'strategies' }
TonelLoader >> baseEditionStrategy: anObject [
	baseEditionStrategy := anObject
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
	self beInteractive
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
TonelLoader >> loadAllMapsWithRequiredMaps [
	
	self configurationMaps do: [:each | each loadWithRequiredMaps ]
]

{ #category : 'loading' }
TonelLoader >> loadApplication: aTonelApplication [

	self loadApplications: (Array with: aTonelApplication)
]

{ #category : 'loading' }
TonelLoader >> loadApplicationNamed: aStringOrSymbol [

	self loadApplication: (self applicationNamed: aStringOrSymbol)
]

{ #category : 'loading' }
TonelLoader >> loadApplications: aCollection [

	| confirmer |
	confirmer := System image confirmer: self.
	[aCollection do: [:each | self basicLoadApplication: each]] 
		ensure: [System image confirmer: confirmer]
]

{ #category : 'loading' }
TonelLoader >> loadApplicationsForPackagesNamed: aCollection [
	"Loads the applications whose package name matches the names in aCollection."
	
	self loadApplications: (aCollection collect: [:each | self applications detect: [:one | one packageName = each]])
]

{ #category : 'loading' }
TonelLoader >> loadApplicationsNamed: aCollection [

	self loadApplications: (aCollection collect: [:each | self applicationNamed: each])
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
		 self loadedConfigurationMaps add: configMap.
		]
]

{ #category : 'accessing' }
TonelLoader >> loadedApplications [

	^loadedApplications ifNil: [loadedApplications := Set new]
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
TonelLoader >> prerequisitesFor: aTonelLoaderApplication current: anOrderedCollection [


	^self prerequisitesStrategy prerequisitesFor: aTonelLoaderApplication current: anOrderedCollection 
]

{ #category : 'strategies' }
TonelLoader >> prerequisitesStrategy [
	^prerequisitesStrategy
]

{ #category : 'strategies' }
TonelLoader >> prerequisitesStrategy: anObject [
	prerequisitesStrategy := anObject
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
TonelLoader >> reset [

	loadedApplications := loadedConfigurationMaps := nil
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoader >> setReader: aTonelReader [

	"Assigns aTonelReader as receiver's reader."
	
	reader := aTonelReader
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

{ #category : 'strategies' }
TonelLoader >> useComputedPrerequisites [
	self prerequisitesStrategy: (TonelLoaderComputedPrerequisitesStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> useGitVersion [
	self versionStrategy: (TonelLoaderGitVersionStrategy for: self)
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

{ #category : 'strategies' }
TonelLoader >> versionFor: aTonelApplication [

	^self versionStrategy versionFor: aTonelApplication
]

{ #category : 'strategies' }
TonelLoader >> versionStrategy [

	^versionStrategy
]

{ #category : 'strategies' }
TonelLoader >> versionStrategy: anObject [

	versionStrategy := anObject
]
