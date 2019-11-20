Class {
	#name : 'TonelLoaderSubApplication',
	#superclass : 'Object',
	#instVars : [
		'name',
		'packageDefinition',
		'loader',
		'prerequisites',
		'subApplications',
		'conditions',
		'hasChanges',
		'poolsAccounted',
		'rootApplication'
	],
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Instance Creation' }
TonelLoaderSubApplication class >> on: aPackageDefinition in: aTonelLoader [

	^(self new)
		setLoader: aTonelLoader;
		setPackageDefinition: aPackageDefinition;
		yourself
]

{ #category : 'configuring' }
TonelLoaderSubApplication >> addPrerequisite: application [

	application ifNotNil: [ :newPrereq |
		(self prerequisites includes: newPrereq)
			ifFalse: [
				newPrereq name = #TonelLoaderApplication ifTrue: [ newPrereq addDependentApplication: self ].
				self prerequisites add: newPrereq ] ]
]

{ #category : 'querying' }
TonelLoaderSubApplication >> allClassesToRemoveIncludingExtensions: aBoolean [

	^(self classesToRemoveIncludingExtensions: aBoolean) asOrderedCollection
		addAll: (
			self subApplications
				inject: OrderedCollection new
				into: [:coll :ea |
					coll
						addAll: (ea allClassesToRemoveIncludingExtensions: aBoolean);
						yourself]);
		yourself
]

{ #category : 'querying' }
TonelLoaderSubApplication >> allClassesWithAssociation [
	| theApp |
	theApp := Smalltalk classAt: self identifier.
	^(self tonelClasses asSet collect: [:class | class -> theApp])
		addAll: (self subApplications inject: Set new
					into: 
						[:coll :subApp | 
						coll
							addAll: subApp allClassesWithAssociation;
							yourself]);
		yourself
]

{ #category : 'querying' }
TonelLoaderSubApplication >> allDefinedClasses [
	"Answer a Dictionary of all the Tonel classes defined
	 in the receiver and the receiver's subapplications."

	^(self tonelDefinedClasses)
		addAll: (
			self subApplications
				inject: Dictionary new
				into: [:coll :each |
					coll
						addAll: each allDefinedClasses;
						yourself]);
		yourself
]

{ #category : 'querying' }
TonelLoaderSubApplication >> availableShadows [
	^SubApplication shadowsFor: self name
]

{ #category : 'configuring' }
TonelLoaderSubApplication >> changeCurrentUserAndSuperGroupSettingOf: theApp [
	"Sets the Super Group setting for @theApp. Note that for doing so, we must first
	 switch the current envy user to the manager of the @theApp.
	 
	Arguments:
		theApp - <Symbol> The application to set the Super Group
	Notes
		This method would be simplified if we can use #changeUserTo:for:. However, that method
		belongs to StS Power Tools and Monticello Importer should be able to load in the IBM image.
	 "
	
	| oldUser newUser |
	oldUser  := EmUser current. 
	newUser := theApp manager.
	(newUser isNil or: [ EmUser current = newUser ])
		ifTrue: [ ^ self changeSuperGroupSettingOf: theApp  ].
	(EmUser classPool declareVariable: 'CurrentUser') value: newUser .
	[
		self changeSuperGroupSettingOf: theApp. 
	] ensure: [
		(EmUser classPool declareVariable: 'CurrentUser') value: oldUser .
	]

]

{ #category : 'configuring' }
TonelLoaderSubApplication >> changeSuperGroupSettingOf: theApp [
	"Read comment of #changeCurrentUserAndSuperGroupSettingOf:"

	theApp updateEdition: [:editionRecord |
			editionRecord 
				inheritedUserFieldAt: 'SuperGroup' 
				put: (self loader class appSuperGroupSetting ifNil: ['none']) asString
	]
]

{ #category : 'configuring',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> checkClassExtensionsExcepting: classNames [
	"Class extensions attempt to add the Application that defines the class being
	 extended as a prerequisite."

	self packageDefinition extendedClasses do: [ :extClass |
		(classNames includes: extClass name) ifFalse: [
			(Smalltalk classAt: extClass name)
				ifNil: [ 
					self error: (TonelMsg03 bindWith: self name with: extClass name) ] 
				ifNotNil: [ :rootClass |
					self addPrerequisite: rootClass controller rootApplication ] ] ].
]

{ #category : 'loading' }
TonelLoaderSubApplication >> checkSuperclassesExcepting: classDefinitions [
	"Class definitions attempt to add the Application that defines their superclass
	 as a prerequisite."

	self definedClasses do: [ :tonelClass |
		(self realSuperclassFor: tonelClass using: classDefinitions) ifNotNil: [ :rootClass | | emRootApp |
			emRootApp := rootClass controller rootApplication.
			emRootApp ~= (Smalltalk classAt: self rootTonelApplication name) ifTrue: [
				self addPrerequisite: emRootApp ] ] ].
				
	self subApplications do: [ :tonelSubApp |
		tonelSubApp checkSuperclassesExcepting: classDefinitions ]
]

{ #category : 'querying' }
TonelLoaderSubApplication >> classesToRemoveIncludingExtensions: aBoolean [
	| theApp classSet |
	
	theApp := Smalltalk classAt: self identifier.
	classSet := theApp defined asSet.
	aBoolean ifTrue: [classSet addAll: theApp extended asSet].
	^classSet
		inject: Set new
		into: 
			 [:removeClasses :eachClass | 
				(eachClass ~= theApp 
					and: [(self includesClass: eachClass name asString) not])
						ifTrue: [removeClasses add: eachClass -> theApp; yourself]
						ifFalse: [removeClasses]]

]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> computePrerequisites [
	
	^OrderedCollection new
]

{ #category : 'querying' }
TonelLoaderSubApplication >> concreteClasses [
	"Returns the list of concrete classes of receiver defined and extended classes.
	 If this is called before creating the classes and extensions, then it might answer a different response.
	 So this is expected to be send after receiver has been loaded into a new or existing edition."

	| realApp |
	 realApp := Smalltalk classAt: self identifier.
	^((self tonelDefinedClasses , self tonelExtendedClasses) collect: [:each | each concreteClassIn: realApp]) asSet asArray
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> conditions [

	conditions ifNil: [self initializeConditions].
	^conditions
]

{ #category : 'loading' }
TonelLoaderSubApplication >> convertSharedPoolClasses [
	
	self tonelDefinedClasses do: [:each | each amendSharedPoolClass ].
	self subApplications do: [:tonelSubApp | tonelSubApp convertSharedPoolClasses]
]

{ #category : 'loading' }
TonelLoaderSubApplication >> createDescriptionFor: theAppOrSubApp [
	"If the receiver has been changed, then attempt to set the description
	 (Notes) for the real (sub)application class. Answer false if the description
	 could not be set; otherwise answer true." 

	^ theAppOrSubApp description: self notes 
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> createEditionIn: parentEmApp underCondition: conditionCode withRoot: emRootApp [

	| emApp |
	(Smalltalk classAt: self identifier ifAbsent: []) ifNil: 
			[((parentEmApp isApplication ifTrue: [Application] ifFalse: [SubApplication]) 
				allNamesWithoutPackages includes: self identifier) 
				ifTrue: [self loadBaseEdition]
				ifFalse: [self createSubApplicationIn: parentEmApp condition: conditionCode]].
	emApp := Smalltalk classAt: self identifier.
	emApp isEdition ifFalse: [emApp newEdition].
	parentEmApp releaseSubApplication: emApp in: conditionCode.
	self changeCurrentUserAndSuperGroupSettingOf: emApp.
	^emApp
]

{ #category : 'loading' }
TonelLoaderSubApplication >> createFor: parentApp underCondition: conditionCode withRoot: rootApp [

	| aSubApp |
	aSubApp := self 
				createEditionIn: parentApp
				underCondition: conditionCode
				withRoot: rootApp.
	self createSubApplicationsFor: aSubApp withRoot: rootApp.
	^aSubApp
]

{ #category : 'loading' }
TonelLoaderSubApplication >> createSubApplicationIn: emParentApp condition: conditionCode [


	| newSubApp defaultConfigurationExpresion |
	defaultConfigurationExpresion := conditionCode = true storeString.
	"defaultConfigurationExpresion 
		ifFalse: [emParentApp addConfigurationExpression: conditionCode ]."
	newSubApp := emParentApp createSubApplication: self identifier in: true storeString.
	"defaultConfigurationExpresion ifFalse: [
		newSubApp configurationExpression: conditionCode ]"
]

{ #category : 'loading' }
TonelLoaderSubApplication >> createSubApplicationsFor: anAppOrSubApp withRoot: rootApp [

	self loadableConditions keysAndValuesDo: 
			[:conditionCode :subApps | 
			subApps do: 
					[:subApp | 
					(subApp hasChangesFor: anAppOrSubApp inRootApp: rootApp) 
						ifTrue: 
							[| emSubApplication |
							emSubApplication := subApp 
										createFor: anAppOrSubApp
										underCondition: conditionCode
										withRoot: rootApp.
							self createDescriptionFor: emSubApplication]]]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> definedClasses [
	^self packageDefinedClasses reject: [:each | each isSharedPool]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> definedSharedPools [
	^self packageDefinedClasses select: [:each | each isSharedPool]
]

{ #category : 'loading' }
TonelLoaderSubApplication >> definePoolDictionariesFor: emParentApp [

	(self hasChangesFor: emParentApp inRootApp: nil) 
		ifTrue: 
			[| theApp |
			theApp := Smalltalk classAt: self identifier.
			self
				definePoolDictionariesForClassesIn: theApp;
				definePoolDictionariesInSubApplicationsFor: theApp]
]

{ #category : 'loading' }
TonelLoaderSubApplication >> definePoolDictionariesForClassesIn: anApp [

	self definedSharedPools do: [:aTonelClass | aTonelClass declarePoolDictionariesIn: anApp].
	self updateSharedPoolsDefinitionOf: anApp.
	self definedSharedPools do: [:aTonelClass | aTonelClass definePoolDictionariesIn: anApp].
]

{ #category : 'loading' }
TonelLoaderSubApplication >> definePoolDictionariesInSubApplicationsFor: anApp [

	self subApplications do: [:tonelSubApp | tonelSubApp definePoolDictionariesFor: anApp]
]

{ #category : 'loading' }
TonelLoaderSubApplication >> deleteRemovedSubApplications [

	self removeDeletedSubApplicationsFor: (Smalltalk classAt: self identifier).
	self subApplications do: [:tonelSubApp | tonelSubApp deleteRemovedSubApplications]
]

{ #category : 'querying' }
TonelLoaderSubApplication >> hasChangesFor: emRootApp inRootApp: rootApp [

	^hasChanges ifNil: [ "poolsAccounted ifFalse: [ self accountForPoolDictionaryClasses ]."

		| emApp |
		hasChanges :=
			(emApp := Smalltalk classAt: self identifier) isNil or: [
				(emApp rootApplication = rootApp) not
					ifTrue: [
						TonelLoaderError signal: (
							TonelMsg05
								bindWith: self name
								with: emApp rootApplication name asString
								with: rootApp name asString) "Subapp belongs to another app in the image"]. "$NLS$ The SubApplication %1 exists in the image, but is a subapplication of %2, not %3"
				(self tonelDefinedClasses anySatisfy: [:tonelClass | tonelClass hasChangesIn: emApp])
					or: [
						(self hasRemovedClassesFor: emApp)
							or: [self subApplicationsHaveChangesFor: emApp inRootApp: rootApp]]]]
]

{ #category : 'querying' }
TonelLoaderSubApplication >> hasRemovedClassesFor: anApp [
	^(self hasRemovedDefinedClassesFor: anApp)
		or: [self hasRemovedExtendedClassesFor: anApp]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> hasRemovedDefinedClassesFor: anApp [
	^anApp defined anySatisfy: [:definedClass |
		(definedClass ~= anApp) and: [
			(self definedClasses anySatisfy: [:each | each name asString = definedClass name asString]) not]]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> hasRemovedExtendedClassesFor: anApp [
	^anApp extended anySatisfy: [:extendedClass |
		(self tonelExtendedClasses includesKey: extendedClass name asString) not]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> identifier [

	^self name asSymbol
]

{ #category : 'querying' }
TonelLoaderSubApplication >> includesClass: className [

	(self tonelClasses keys allSatisfy: [:each | each isSymbol]) ifFalse: [self halt].
	^self tonelClasses includesKey: className asSymbol
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> initialize [

	| theApp |

	theApp := Smalltalk classAt: self identifier.
	(theApp class includesSelector: #loaded) ifTrue: [theApp loaded].
	self subApplications do: [:each | each initialize]
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> initializeConditions [

	conditions := Dictionary new.
	self packageDefinition metadata
		at: #vaSubApplications
		ifPresent: [:packageConditions |
			packageConditions do: [:condition |
				conditions
					at: (condition at: #condition)
					put: (
						(condition at: #subapps)
							collect: [:subAppName | self loader subApplicationNamed: subAppName])]].
	^conditions
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> initializeSubApplications [

	self initializeSubApplicationsWithRoot: self rootTonelApplication
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> initializeSubApplicationsWithRoot: rootTonelApplication [
	"Forces the initalization and lookup of receiver sub applications."

	| conditionsSubApps |
	conditionsSubApps := Set new.
	self conditions keysAndValuesDo: [:conditionCode :subApps |
		(SubApplication isExpressionValid: conditionCode)
			ifTrue: [
					subApps do: [:each | 
					conditionsSubApps add: each.
					each rootTonelApplication: self rootTonelApplication]
			]	
			ifFalse: [ self logIgnoredShadowSubapps: subApps ]
	].
	subApplications := conditionsSubApps asOrderedCollection
]

{ #category : 'querying' }
TonelLoaderSubApplication >> loadableConditions [

	| loadableConditions |
	loadableConditions := Dictionary  new.
	self conditions keysAndValuesDo: [:conditionString :subApps | 
		(SubApplication isExpressionValid: conditionString) ifTrue: [
			loadableConditions at: conditionString put: subApps 
		]
	].
	^loadableConditions
	
]

{ #category : 'loading' }
TonelLoaderSubApplication >> loadBaseEdition [
	"This method contains some voodoo."

	| baseEdition loadResult |

	baseEdition :=
		(CwListPrompter new)
			messageString: (TonelMsg06 bindWith: self name);
			items: self availableShadows;
			printBlock: [:ea | TonelMsg07 bindWith: ea signature with: ea timeStamp];
			prompt. "$NLS$ Application %1 exists but is not loaded. Please choose a base version." "$NLS$ %1 %2"

	baseEdition ifNil: [TonelLoaderError signal: (TonelMsg08 bindWith: self name)]. "$NLS$ You need to choose a base edition from which to create %1"
	(EmImageBuilder loadApplications: (EtBrowser new findAllApplicationsToLoadWith: (Array with: baseEdition))) ifNil: [
		TonelLoaderError signal: (TonelMsg18 bindWith: self name) "$NLS$ Could not load base edition of %1. Load aborted."
	]
	
]

{ #category : 'loading' }
TonelLoaderSubApplication >> loadClassesIn: anApp [

		(self 
		topologicallySort:self tonelExtendedClasses 
		in: anApp) do: [:each | each key loadInto: anApp].
	(self 
		topologicallySort: (self tonelClasses reject: [:each1 | each1 isSharedPool])
		in: anApp) do: [:each | each key loadInto: anApp]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> loader [

	^loader
]

{ #category : 'loading' }
TonelLoaderSubApplication >> loadFor: aLoader [
	"Load the real application for @aLoader."
	
	self hasChanges ifTrue: [ | theApp |
		theApp := Smalltalk classAt: self identifier.
		self 
			loadClassesIn: theApp;
			versionClassesIn: theApp for: aLoader;
			loadSubApplicationsIn: theApp for: aLoader ]
]

{ #category : 'loading' }
TonelLoaderSubApplication >> loadFor: theRootApp as: versionName [

	(self hasChangesFor: theRootApp inRootApp: nil) 
		ifTrue: 
			[| theApp |
			theApp := Smalltalk classAt: self identifier.
			self
				loadClassesIn: theApp;
				versionClassesIn: theApp as: versionName;
				loadSubApplicationsFor: theApp as: versionName;
				removeDeletedSubApplicationsFor: theApp;
				version: theApp as: versionName]
]

{ #category : 'loading' }
TonelLoaderSubApplication >> loadSubApplicationsFor: anApp as: versionName [

	(self subApplications) do: [:tonelSubApp | tonelSubApp loadFor: anApp as: versionName]
]

{ #category : 'loading' }
TonelLoaderSubApplication >> loadSubApplicationsIn: anApp for: aLoader [

	self subApplications do: [ :subApp |
		subApp loadFor: anApp as: aLoader versionName ]
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> logIgnoredShadowSubapps: aCollection [

	Transcript
		show: (
			String streamContents: [:stream |
				stream nextPutAll: TonelMsg19. "$NLS$ The following subapplications were not imported: "
				aCollection
					do: [:each | stream nextPutAll: each name]
					separatedBy: [stream nextPutAll: ', ']]);
		cr
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> name [

	^name ifNil: [name := self packageDefinition appName]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> notes [
		
	^self rootTonelApplication notes
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> packageDefinedClasses [
	^self packageDefinition definedClasses
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> packageDefinition [

	^packageDefinition
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> packageName [

	^ self packageDefinition name asString
		
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> prerequisites [

	^prerequisites ifNil: [prerequisites := self computePrerequisites]
]

{ #category : 'printing' }
TonelLoaderSubApplication >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $<;
	nextPutAll: self name;
	nextPut: $>
]

{ #category : 'querying' }
TonelLoaderSubApplication >> realSuperclassFor: aTonelClassDefinition using: tonelSuperclasses [
	"Answer a concrete superclass for @aTonelClassDefinition.
	 This may entail climbing the class hierarchy of classes in @tonelSuperclasses
	 since they represent classes that are being defined and do not
	 have concrete superclasses yet. If a concrete superclass
	 isn't found, answer nil."

	| aClassDefinition |

	aClassDefinition := aTonelClassDefinition.
	[aClassDefinition ~= nil] whileTrue: [
		(Smalltalk classAt: aClassDefinition superclassIdentifier)
			ifNil: [
				aClassDefinition :=
					tonelSuperclasses detect: [:aPotentialSuperclass |
						aPotentialSuperclass identifier = aClassDefinition superclassIdentifier] ifNone: [
						TonelLoaderError signal: (TonelMsg10 bindWith: aClassDefinition superclassIdentifier) 
						]]
			ifNotNil: [:rootClass | ^rootClass]].

	self halt: (
		TonelMsg04
			bindWith: self name
			with: aTonelClassDefinition name
			with: aTonelClassDefinition superclassIdentifier asString). "$NLS$ %1 defines %2 as a subclass of %3, which is not defined in the image"
	^nil



]

{ #category : 'querying' }
TonelLoaderSubApplication >> removeDeletedSubApplicationsFor: theApp [

	theApp subApplications do: [:subApp |
		(self subApplications anySatisfy: [:tonelSubApp | tonelSubApp identifier = subApp name])
			ifFalse: [
				theApp
					deleteSubApplicationNamed: subApp name from: 'true'; "$NON-NLS$"
					removeSubApplication: subApp]]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> rootTonelApplication [
	"Answer the Tonel application in which the receiver is a subApp."

	^rootApplication
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> rootTonelApplication: aTonelLoaderApplication [
	
	rootApplication := aTonelLoaderApplication
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> setLoader: aTonelLoader [

	loader := aTonelLoader
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> setPackageDefinition: aPackageDefinition [

	packageDefinition := aPackageDefinition
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> subApplications [
	subApplications ifNil: [self initializeSubApplications].
	^subApplications
]

{ #category : 'querying' }
TonelLoaderSubApplication >> subApplicationsHaveChangesFor: theApp inRootApp: rootApp [

	^(self subApplications 
		anySatisfy: [:aTonelSubApp | aTonelSubApp hasChangesFor: theApp inRootApp: rootApp]) 
			or: 
				[theApp subApplications anySatisfy: 
						[:definedSubApp | 
						self subApplications 
							noneSatisfy: [:aTonelSubApp | aTonelSubApp identifier = definedSubApp name]]]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> tonelClasses [
	"Returns the list of classed defined and extended by receiver."

	^self tonelDefinedClasses , self tonelExtendedClasses
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> tonelDefinedClasses [

	| definedClasses |

	definedClasses := Dictionary new.
	self packageDefinition classDefinitions
		keysDo: [:key | key name = self name ifFalse: [definedClasses at: key name asSymbol put: key]].
	^definedClasses
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> tonelExtendedClasses [
	
	| extendedClasses |

	extendedClasses := Dictionary new.
	self packageDefinition extensions keysDo: [:key | extendedClasses at: key name asSymbol put: key].
	^extendedClasses
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> topologicallySort: aDictionary in: anApp [
	^(aDictionary values collect: [:each | each -> anApp]) tonelSingleEdgeTopologicallySortedCollection
]

{ #category : 'loading' }
TonelLoaderSubApplication >> updateSharedPoolsDefinitionOf: anApp [
	"Updates the app class definition to reference the shared pools classes it declares."
	
	| updatedSharedPoolsNames |
	updatedSharedPoolsNames := Set new.
	updatedSharedPoolsNames addAll: anApp sharedPoolNames.
	updatedSharedPoolsNames addAll: ((self definedSharedPools) collect: [:ea | ea identifier asSymbol]).
	
	anApp creatorClass
				createClassNamed: anApp environmentKey
				in: anApp environment
				for: (anApp hasController ifTrue: [anApp controller] ifFalse: [nil])
				subclassOf: anApp superclass
				instanceShape: anApp instanceShape
				classInstanceVariables: (anApp class instVarNames)
				instanceVariables: (anApp instVarNames)
				classVariables: (anApp classVarNames)
				sharedPoolNames: updatedSharedPoolsNames asArray
	
]

{ #category : 'versioning' }
TonelLoaderSubApplication >> version: anApp as: versionName [
	"If @versionName has not been provided, leave the open edition
	 of @anApp as-is and answer self; otherwise make a version of @anApp."

	versionName isEmpty ifFalse: [anApp versionName: versionName]
]

{ #category : 'versioning' }
TonelLoaderSubApplication >> versionClassesIn: anApp as: versionName [

	self tonelClasses do: [:aTonelClass | aTonelClass versionIn: anApp as: versionName]
]

{ #category : 'versioning' }
TonelLoaderSubApplication >> versionClassesIn: anApp for: aLoader [

	(self tonelClasses reject: [:each | each isSharedPool]) do: [:each | each versionIn: anApp for: aLoader]
]

{ #category : 'versioning' }
TonelLoaderSubApplication >> versionFor: aLoader [

	| theApp |

	theApp := Smalltalk classAt: self identifier.
	self subApplications do: [:aTonelSubApp | aTonelSubApp versionFor: aLoader].
	theApp isEdition ifFalse: [^self].
	(self concreteClasses allSatisfy: [:each | each isVersionIn: theApp]) ifFalse: [^self].
	(theApp isEditionIn: theApp) ifTrue: [
			theApp versionNameIn: theApp is: aLoader versionName.
			theApp releaseClass: theApp ].
	self version: theApp as: aLoader versionName
]
