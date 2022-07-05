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
		'autogenerateInstanceInitializers',
		'loadsRequiredMaps'
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

{ #category : 'resolving' }
TonelLoader >> addPrerequisite: emApplication to: tonelApplication [
	"Adds emApplication as a prerequisite of tonelApplication."

	self prerequisitesStrategy addPrerequisite: emApplication to: tonelApplication
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
	"Returns the application with name aString or raise an error if not found.
	 
	 Answers:
		<TonelLoaderApplication>
	 "

	^self applications detect: [:one | one name asSymbol = aString asSymbol]
]

{ #category : 'lookup' }
TonelLoader >> applicationNamed: aString ifNone: aBlock [
	"Returns the application with name aString or evaluate aBlock if none is found.
	 
	 Answers:
		<TonelLoaderApplication>
	 "

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

	^autogenerateInstanceInitializers ifNil: [false]
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
	"Change the current ENVY Library user to be emUser during the execution of aBlock,
	 restoring the original user after it."

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

{ #category : 'accessing' }
TonelLoader >> computeSettings [
	^self class settings copyFor: self
]

{ #category : 'strategies' }
TonelLoader >> configMapResolver [
	^self settings configMapResolver
]

{ #category : 'strategies' }
TonelLoader >> configMapResolver: aTonelLoaderConfigMapResolver [

	self settings configMapResolver: (aTonelLoaderConfigMapResolver setLoader: self)
]

{ #category : 'lookup' }
TonelLoader >> configurationMapNamed: aString ts: anEmTimeStamp versionName: versionName [
	"Looks into the Configuration Maps of receiver for a configuration map
	 that matches name, timestamp and version name.
	 Answer a TonelConfigurationMap if found or a new TonelEmConfigurationMap 
	 with the searched name, timestamp and version name.
	 
	 Answers:
		<TonelConfigurationMap>
	 "
	 
	^self
		configurationMapNamed: aString
		ts: anEmTimeStamp
		versionName: versionName
		ifNone: [
			(TonelEmConfigurationMapReference name: aString ts: anEmTimeStamp seconds versionName: versionName)
				loader: self;
				yourself]
]

{ #category : 'lookup',
  #vaVisibility : 'private' }
TonelLoader >> configurationMapNamed: aString ts: anEmTimeStamp versionName: versionName ifNone: aBlock [
	"Delegates into receiver config maps resolver to find one that matches the passed arguments,
	 evaluate aBlock if there is none."

	^self configMapResolver
		configurationMapNamed: aString
		ts: anEmTimeStamp
		versionName: versionName
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
	^createsHookMethods ifNil: [false]
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
	"Answer whether there is an edition for aTonelAppOrSubApp
	 that can be used its base edition, delegating it to receivers base edition strategy."
	
	^self baseEditionStrategy hasSelectableBaseEditionFor: aTonelAppOrSub
]

{ #category : 'privileges' }
TonelLoader >> hasSuperGroupAccessTo: anApplication [
	"Answer whether the super user mode is enabled to access anApplication.
	 A super user, or super group, can bypass all the security checkpoints of ENVY."

	^self class hasSTSSupport
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
	"Loads all the applications read from the receiver reader's repository."
	
	^self loadApplications: self applications
]

{ #category : 'loading' }
TonelLoader >> loadAllConfigurationMaps [
	"Loads all the configuration maps read from the receiver reader's repository."

	self loadConfigurationMaps: self configurationMaps
	
	
]

{ #category : 'loading' }
TonelLoader >> loadAllMapsWithoutRequiredMaps [
	"Loads all the configuration maps read from the receiver reader's repository
	 together without the required maps of each of them that are not 
	 in the list of required maps.
	 
	 It means that if a Tonel configuration map requires another 
	 Tonel configuration map, it will be loaded."

	self loadConfigurationMaps: self configurationMaps
]

{ #category : 'loading' }
TonelLoader >> loadAllMapsWithRequiredMaps [
	"Loads all the configuration maps read from the receiver reader's repository
	 together with the required maps of each of them."

	self loadConfigurationMaps: self configurationMaps
]

{ #category : 'loading' }
TonelLoader >> loadApplication: aTonelApplication [
	"Loads aTonelApplication."

	| emApps |

	emApps := (self loadApplications: (Array with: aTonelApplication)).
	^emApps isEmpty ifFalse: [emApps first]
]

{ #category : 'loading' }
TonelLoader >> loadApplicationForPackageNamed: aString [

	"Load the applications whose package name matches aString."

	^self loadApplication: (self applicationForPackageNamed: aString)
]

{ #category : 'loading' }
TonelLoader >> loadApplicationNamed: aStringOrSymbol [
	"Loads a TonelApplication with a name matching aStringOrSymbol."
	
	^self loadApplication: (self applicationNamed: aStringOrSymbol)
]

{ #category : 'loading' }
TonelLoader >> loadApplications: aCollection [
	"Loads aCollection of <TonelApplication>."

	| confirmer oldWarningLevel emUser |

	emUser := EmUser current.
	confirmer := System image confirmer: self.
	oldWarningLevel := EsCompiler defaultWarningLevel.
	EsCompiler defaultWarningLevel: self settings compilerWarningLevel.
	[aCollection do: [:each | self basicLoadApplication: each]] ensure: [
		(EmUser classPool declareVariable: 'CurrentUser') value: emUser.
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
	"Loads a TonelApplication with a name matching aStringOrSymbol."

	^self loadApplications: (aCollection collect: [:each | self applicationNamed: each])
]

{ #category : 'interacting' }
TonelLoader >> loadBaseEditionFor: aTonelApplication [

	^self baseEditionStrategy loadBaseEditionFor: aTonelApplication
]

{ #category : 'loading' }
TonelLoader >> loadConfigurationMap: aTonelConfigurationMap withPrereqs: aBoolean [
	"Loads aTonelConfigurationMap with a name matching aString,
	 also loading its prerequisites if aBoolean is true."

	aBoolean
		ifTrue: [aTonelConfigurationMap loadWithRequiredMaps]
		ifFalse: [aTonelConfigurationMap load].
	^self loadedConfigurationMaps add: aTonelConfigurationMap
]

{ #category : 'loading' }
TonelLoader >> loadConfigurationMapNamed: aString [
	
	self loadConfigurationMapNamed: aString withPrereqs: self loadsRequiredMaps
]

{ #category : 'loading' }
TonelLoader >> loadConfigurationMapNamed: aString withPrereqs: aBoolean [
	"Loads a TonelConfigurationMap with a name matching aString,
	 also loading its prerequisites if aBoolean is true."

	(self configurationMaps detect: [:one | one name = aString]) 
		ifNotNil: [:configMap | self loadConfigurationMap: configMap withPrereqs: aBoolean]
]

{ #category : 'loading' }
TonelLoader >> loadConfigurationMaps: aCollection [
	"Loads aCollection of TonelConfigurationMaps."
	
	aCollection do: [:each | each loadWithRequiredMaps: self loadsRequiredMaps ]
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

{ #category : 'accessing' }
TonelLoader >> loadsRequiredMaps [
	"Answer whether receiver will load the required maps of each Configuration Map when loading them."

	^loadsRequiredMaps ifNil: [loadsRequiredMaps := true]
]

{ #category : 'accessing' }
TonelLoader >> loadsRequiredMaps: aBoolean [
	"Sets whether receiver will load the required maps of each Configuration Map when loading them."

	loadsRequiredMaps := aBoolean
]

{ #category : 'logging' }
TonelLoader >> log: aString [
	"Logs aString to the Transcript."

	Transcript show: aString; cr.
]

{ #category : 'strategies-convenience' }
TonelLoader >> mapTagsToSubapplications [
	"Configures receiver to map Package tags to subapplications when loading.
	 Read more: <https://github.com/instantiations/tonel-vast/blob/master/docs/strategies.md#tonelloadersubapplicationstagmappingstrategy>"
	 

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

{ #category : 'strategies' }
TonelLoader >> packageDependencyStrategy [
	^self settings packageDependencyStrategy
]

{ #category : 'strategies' }
TonelLoader >> packageDependencyStrategy: aTonelLoaderPackageDependencyStrategy [
	self settings packageDependencyStrategy: (aTonelLoaderPackageDependencyStrategy setLoader: self)
]

{ #category : 'accessing' }
TonelLoader >> packageNames [
	
	^self reader packages collect: [:each | each name asString ]
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoader >> postLoadActions [
	^(Smalltalk classAt: #StsPowerTools) 
		ifNotNil: [:class | class perform: #primRefreshMethodSelectors]
]

{ #category : 'resolving' }
TonelLoader >> prerequisitesFor: aTonelLoaderApplication current: anOrderedCollection [
	"Answer a collection of EmShadowApplication that are the prerequistes application of aTonelApplication together
	 with aCollection of Applications.
	 
	 Answers:
		<EmShadowApplication>
	 "

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

{ #category : 'strategies-convenience' }
TonelLoader >> resolveToLatestConfigMaps [
	self configMapResolver: (TonelLoaderConfigMapResolverLatest for: self)
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
TonelLoader >> shouldLoadPrerequisiteApplication: anApplication [
	"Answer whether receiver should load the prerequisite application anApplication."

	^(self applications anySatisfy: [:any | any name asSymbol = anApplication name]) 
		and: 
			[self loadedApplications 
				noneSatisfy: [:each | each name asSymbol = anApplication name]]
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
	"Updates the prerequisites of receiver applications, 
	 replacing prerequisites defined as instances of TonelLoaderApplication 
	 by their correspondent EmApplication."

	self applications
		do: [:tonelApp | tonelApp replacePrerequisite: aTonelLoaderApplication emApplication]
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
TonelLoader >> usePackageDependencyTable [

	self packageDependencyStrategy: (TonelLoaderPackageDependencyTableStrategy for: self).
	^self packageDependencyStrategy
]

{ #category : 'strategies-convenience' }
TonelLoader >> useSpecifiedVersion: versionName [
	self versionStrategy: ((TonelLoaderSpecifiedVersionStrategy for: self) versionName: versionName)
]

{ #category : 'resolving' }
TonelLoader >> versionFor: anAppOrSubapp [
	"Answer the version for anAppOrSubapp, 
	 delegating the decision to receiver's version strategy."

	^self versionStrategy versionFor: anAppOrSubapp
]

{ #category : 'strategies' }
TonelLoader >> versionStrategy [

	^self settings versionStrategy
]

{ #category : 'strategies' }
TonelLoader >> versionStrategy: aTonelLoaderVersionStrategy [

	self settings versionStrategy: (aTonelLoaderVersionStrategy setLoader: self)
]
