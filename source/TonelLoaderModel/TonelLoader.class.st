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
		'loadedConfigurationMaps',
		'createsHookMethods',
		'autogenerateInstanceInitializers'
	],
	#classVars : [
		'DefaultAppNameSuffix',
		'CompilerWarningLevel',
		'AppSuperGroupSetting'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'STS-Support' }
TonelLoader class >> do: aBlock forApp: app withSuperUser: user [

	^self hasSTSSupport 
		ifTrue: [super do: aBlock forApp: app withSuperUser: user]
		ifFalse: [aBlock value]
]

{ #category : 'STS-Support' }
TonelLoader class >> hasSTSSupport [

	^(Smalltalk includesKey: #AbtOrganizerApp)
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

{ #category : 'Accessing' }
TonelLoader class >> settings [

	^TonelLoaderSettings default
]

{ #category : 'accessing' }
TonelLoader >> addLoadedApplication: aTonelApplication [

	self loadedApplications add: aTonelApplication.
	self updatePrerequisitesFrom: aTonelApplication
]

{ #category : 'strategies-convenience' }
TonelLoader >> alwaysCreateEditions [

	^self versionStrategy alwaysCreateEditions
]

{ #category : 'loading' }
TonelLoader >> applicationForPackageNamed: aString [

	^self applications detect: [:one | one packageName = aString]
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

{ #category : 'accessing' }
TonelLoader >> autogenerateInstanceInitializers [
	"Answer whether receiver will create class side instance creation methods that send #initialize to
	 its newly created instances."

	^autogenerateInstanceInitializers
]

{ #category : 'accessing' }
TonelLoader >> autogenerateInstanceInitializers: aBoolean [
	autogenerateInstanceInitializers := aBoolean
]

{ #category : 'strategies' }
TonelLoader >> baseEditionStrategy [
	^self settings baseEditionStrategy
]

{ #category : 'strategies' }
TonelLoader >> baseEditionStrategy: aTonelLoaderBaseEditionStrategy [
	self settings baseEditionStrategy: (aTonelLoaderBaseEditionStrategy setLoader: self)
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoader >> basicLoadApplication: aTonelApplication [

	aTonelApplication prerequisites do: 
			[:prereq | 
			(self shouldLoadPrerequisiteApplication: prereq) 
				ifTrue: [self basicLoadApplication: (self applicationNamed: prereq name)]].
	(self loadedApplications includes: aTonelApplication) 
		ifFalse: [(TonelApplicationLoader on: aTonelApplication in: self) load]
]

{ #category : 'strategies-convenience' }
TonelLoader >> beUnattended [
	self useComputedPrerequisites.
	self useLatestBaseEditions.
	self doNotCreateVersions
]

{ #category : 'privileges' }
TonelLoader >> changeUserTo: emUser for: aBlock [

	| oldUser newUser |

	oldUser := EmUser current.
	newUser := emUser.
	(newUser isNil or: [EmUser current = newUser]) ifTrue: [^aBlock value].
	(EmUser classPool declareVariable: 'CurrentUser') value: newUser.
	^[aBlock value] ensure: [(EmUser classPool declareVariable: 'CurrentUser') value: oldUser]
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoader >> checkRepositoryContents [
	self applications isEmpty 
		ifTrue: 
			[self error: 'The selected directory does not contain any Tonel Package']
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoader >> computeSettings [
	^self class settings copyFor: self
]

{ #category : 'lookup' }
TonelLoader >> configurationMapNamed: aString ts: anEmTimeStamp versionName: versionName [

	^self
		configurationMapNamed: aString
		ts: anEmTimeStamp
		versionName: versionName
		ifNone: [
			(TonelEmConfigurationMap name: aString ts: anEmTimeStamp seconds versionName: versionName)
				loader: self;
				yourself]
]

{ #category : 'lookup',
  #vaVisibility : 'private' }
TonelLoader >> configurationMapNamed: aString ts: anEmTimeStamp versionName: versionName ifNone: aBlock [

	^self configurationMaps
		detect: [:one |
			one name = aString and: [one timeStamp = anEmTimeStamp or: [one versionName = versionName]]]
		ifNone: aBlock
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

{ #category : 'accessing' }
TonelLoader >> createsHookMethods [
	^createsHookMethods
]

{ #category : 'accessing' }
TonelLoader >> createsHookMethods: anObject [
	createsHookMethods := anObject
]

{ #category : 'strategies-convenience' }
TonelLoader >> doNotCreateVersions [
	self versionStrategy: (TonelLoaderNoVersionStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> doNotUseBaseEditions [
	self baseEditionStrategy: (TonelLoaderNoBaseEditionStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> forceCreationOfEditions [
	
	self versionStrategy alwaysCreateEditions: true
]

{ #category : 'privileges' }
TonelLoader >> hasSelectableBaseEditionFor: aTonelAppOrSub [
	
	^self baseEditionStrategy hasSelectableBaseEditionFor: aTonelAppOrSub
]

{ #category : 'privileges' }
TonelLoader >> hasSuperGroupAccessTo: anApplication [

	^TonelLoader class hasSTSSupport
		ifTrue: [
			(self settings appSuperGroupSetting notNil
				and: [self settings appSuperGroupSetting = anApplication stsSuperGroupSetting])
					or: [anApplication stsIsSuperGroup]]
		ifFalse: [false]
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoader >> initialize [

	super initialize.
	createsHookMethods := false.
	autogenerateInstanceInitializers := false
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoader >> initializeApplications [
	"Initializes receiver applications ensuring each application initializes its subapplications deeply."

	applications :=
		(reader packages select: [:each | each parent isNil])
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
	
	self loadConfigurationMaps: self configurationMaps
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

	^self loadApplication: (self applicationForPackageNamed: aString)
]

{ #category : 'loading' }
TonelLoader >> loadApplicationNamed: aStringOrSymbol [

	^self loadApplication: (self applicationNamed: aStringOrSymbol)
]

{ #category : 'loading' }
TonelLoader >> loadApplications: aCollection [

	| confirmer oldWarningLevel emUser |
	emUser := EmUser current.
	confirmer := System image confirmer: self.
	oldWarningLevel := EsCompiler defaultWarningLevel.
	EsCompiler defaultWarningLevel: self settings compilerWarningLevel.
	[aCollection do: [:each | self basicLoadApplication: each]] ensure: 
			[(EmUser classPool declareVariable: 'CurrentUser') value: emUser.
			System image confirmer: confirmer.
			EsCompiler defaultWarningLevel: oldWarningLevel.
			self postLoadActions].
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

{ #category : 'loading' }
TonelLoader >> loadConfigurationMaps: aCollection [
	
	aCollection do: [:each | each loadWithRequiredMaps ]
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

	Transcript show: aString; cr.
]

{ #category : 'strategies-convenience' }
TonelLoader >> mapTagsToSubapplications [

	self subapplicationsStrategy: (TonelLoaderSubapplicationsTagMappingStrategy for: self)
]

{ #category : 'strategies' }
TonelLoader >> namingStrategy [
	^self settings namingStrategy
]

{ #category : 'strategies' }
TonelLoader >> namingStrategy: aTonelLoaderNamingStrategy [
	self settings namingStrategy: (aTonelLoaderNamingStrategy setLoader: self)
]

{ #category : 'accessing' }
TonelLoader >> packageNames [
	
	^self reader packages collect: [:each | each name asString ]
]

{ #category : 'strategies' }
TonelLoader >> packagePrerequisitesStrategy [
	^self settings packagePrerequisitesStrategy
]

{ #category : 'strategies' }
TonelLoader >> packagePrerequisitesStrategy: aTonelLoaderPackagePrereqsStrategy [
	self settings packagePrerequisitesStrategy: (aTonelLoaderPackagePrereqsStrategy setLoader: self)
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoader >> postLoadActions [
	^(Smalltalk classAt: #StsPowerTools) 
		ifNotNil: [:class | class perform: #primRefreshMethodSelectors]
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
TonelLoader >> prerequisitesStrategy: aTonelLoaderApplicationPrereqStrategy [
	self settings prerequisitesStrategy: (aTonelLoaderApplicationPrereqStrategy setLoader: self)
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

	| candidateApps |

	candidateApps :=
		(self applications select: [:tonelApp |
			(tonelApp allDefinedClasses anySatisfy: [:tonelClass |
				tonelClass = aTonelReaderClassDefinition
					or: [tonelClass name = aTonelReaderClassDefinition name]])])
						flattened
							collect: [:tonelApp | tonelApp rootTonelApplication].
	^candidateApps isEmpty ifTrue: [nil] ifFalse: [candidateApps first]
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
	^settings ifNil: [settings := self computeSettings]
]

{ #category : 'accessing' }
TonelLoader >> settings: anObject [
	settings := anObject
]

{ #category : 'loading' }
TonelLoader >> shouldLoadPrerequisiteApplication: prereq [

	^(self applications anySatisfy: [:any | any name asSymbol = prereq name]) 
		and: 
			[self loadedApplications 
				noneSatisfy: [:each | each name asSymbol = prereq name]]
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

{ #category : 'strategies' }
TonelLoader >> subapplicationsStrategy [
	^self settings subapplicationsStrategy
]

{ #category : 'strategies' }
TonelLoader >> subapplicationsStrategy: aTonelLoaderSubapplicationsMappingStrategy [

	self settings subapplicationsStrategy: (aTonelLoaderSubapplicationsMappingStrategy setLoader: self)
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

{ #category : 'loading' }
TonelLoader >> updatePrerequisitesFrom: aTonelLoaderApplication [

	self applications do: [:tonelApp |
		tonelApp replacePrerequisite: aTonelLoaderApplication emApplication]
]

{ #category : 'strategies-convenience' }
TonelLoader >> useApplicationPrerequisitesTable [

	self prerequisitesStrategy: (TonelLoaderApplicationPrereqsTableStrategy for: self).
	^self prerequisitesStrategy
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
TonelLoader >> useLatestBaseEditions [
	self baseEditionStrategy: (TonelLoaderLatestBaseEditionStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> usePackagePrerequisitesTable [

	self packagePrerequisitesStrategy: (TonelLoaderPackageTablePrereqsStrategy for: self).
	^self packagePrerequisitesStrategy
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
TonelLoader >> versionStrategy: aTonelLoaderVersionStrategy [

	self settings versionStrategy: (aTonelLoaderVersionStrategy setLoader: self)
]
