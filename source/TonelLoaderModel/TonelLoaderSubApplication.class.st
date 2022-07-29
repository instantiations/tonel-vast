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
		'rootApplication',
		'emApplication'
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

{ #category : 'comparing' }
TonelLoaderSubApplication >> <= aTonelLoaderSubapplication [

	^self identifier <= aTonelLoaderSubapplication identifier
]

{ #category : 'initializing' }
TonelLoaderSubApplication >> addAllSubApplicationsTo: collection [
	"Private - Add all the receiver's sub-applications to collection in
	 hierarchical order. SubApplications at the same hierarchical level
	 are sorted alphabetically."

	| subApp |

	self subApplications size = 1
		ifTrue: [
			subApp := collection add: self subApplications first.
			subApp subApplications notEmpty ifTrue: [subApp addAllSubApplicationsTo: collection]]
		ifFalse: [
			(self subApplications asSortedCollection) do: [:sub |
				collection add: sub.
				sub subApplications notEmpty ifTrue: [sub addAllSubApplicationsTo: collection]]]
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
		addAll: (
			self subApplications
				inject: Set new
				into: [:coll :subApp |
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
TonelLoaderSubApplication >> allExtendedClasses [
	
	^(self tonelExtendedClasses)
		addAll: (
			self subApplications
				inject: Dictionary new
				into: [:coll :each |
					coll
						addAll: each allExtendedClasses;
						yourself]);
		yourself
]

{ #category : 'querying' }
TonelLoaderSubApplication >> availableShadows [
	^self emClass shadowsFor: self name
]

{ #category : 'configuring' }
TonelLoaderSubApplication >> changeCurrentUserAndSuperGroupSettingOf: theApp [


	self loader changeUserTo: theApp manager for: [ self changeSuperGroupSettingOf: theApp  ]
]

{ #category : 'configuring' }
TonelLoaderSubApplication >> changeSuperGroupSettingOf: theApp [
	"Updates the super group setting to that set in the loader settings, 
	 or to the one in theApp, if defined."

	TonelLoader hasSTSSupport
		ifTrue: [
			theApp updateEdition: [:editionRecord |
				editionRecord
					inheritedUserFieldAt: 'SuperGroup'
					put:
						(self loader settings appSuperGroupSetting
							ifNil: [theApp stsSuperGroupSetting])
								asString]]
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
					self loader addPrerequisite: rootClass controller rootApplication to: self] ] ].
]

{ #category : 'loading' }
TonelLoaderSubApplication >> checkSuperclassesExcepting: classDefinitions [
	"Class definitions attempt to add the Application that defines their superclass
	 as a prerequisite."

	self definedClasses do: [:tonelClass |
		(self realSuperclassFor: tonelClass using: classDefinitions) ifNotNil: [:rootClass | |
			  emRootApp |
			emRootApp := rootClass controller rootApplication.
			emRootApp ~= (Smalltalk classAt: self rootTonelApplication name asSymbol)
				ifTrue: [self loader addPrerequisite: emRootApp to: self]]].

	self subApplications
		do: [:tonelSubApp | tonelSubApp checkSuperclassesExcepting: classDefinitions]
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
					and: [(self includesClassNamed: eachClass name asSymbol) not])
						ifTrue: [removeClasses add: eachClass -> theApp; yourself]
						ifFalse: [removeClasses]]

]

{ #category : 'querying' }
TonelLoaderSubApplication >> classesWithAssociation [

	| theApp |

	theApp := Smalltalk classAt: self identifier.
	^(self tonelClasses asSet collect: [:class | class -> theApp])
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> computeHasChangesFor: emAppOrSubApp inRootApp: emRootApplication [

	emAppOrSubApp rootApplication ~= emRootApplication 
		ifTrue: 
			[TonelLoaderError signal: (TonelMsg05 
						bindWith: self name
						with: emAppOrSubApp rootApplication name asString
						with: emRootApplication name asString)	"Subapp belongs to another app in the image"].	"$NLS$ The SubApplication %1 exists in the image, but is a subapplication of %2, not %3"
	^hasChanges := (self hasClassChangesComparedTo: emAppOrSubApp) or: 
					[(self hasRemovedClassesFor: emAppOrSubApp) or: 
							[self subApplicationsHaveChangesFor: emAppOrSubApp
								inRootApp: emRootApplication]]
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> computeName [
	^self loader namingStrategy nameForSubApp: self
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> computePrerequisites [
	"SubApplications don't have prerequisites."
	
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
	"Answer the load conditions of receiver."

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

	theAppOrSubApp description = self notes ifFalse: [
		^theAppOrSubApp description: self notes 
	].
	^false
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> createEditionIn: parentEmApp underCondition: conditionCode withRoot: emRootApp [

	| emApp |

	(Smalltalk classAt: self identifier ifAbsent: []) ifNil: [
		(self loader hasSelectableBaseEditionFor: self)
			ifTrue: [self loadBaseEdition]
			ifFalse: [self createSubApplicationIn: parentEmApp condition: conditionCode]].
	emApp := Smalltalk classAt: self identifier.


	self loader
		changeUserTo: emApp manager 
		for: [
			emApp isEdition ifFalse: [(emApp newEdition)].
			self changeCurrentUserAndSuperGroupSettingOf: emApp.
			parentEmApp releaseSubApplication: emApp in: conditionCode.
			].

	^emApp
]

{ #category : 'loading' }
TonelLoaderSubApplication >> createFor: parentApp underCondition: conditionCode withRoot: rootApp [

	emApplication := self createEditionIn: parentApp underCondition: conditionCode withRoot: rootApp.
	self createSubApplicationsFor: emApplication withRoot: rootApp.
	^emApplication
]

{ #category : 'loading' }
TonelLoaderSubApplication >> createSubApplicationIn: emParentApp condition: conditionCode [

	| newSubApp defaultConfigurationExpresion |

	defaultConfigurationExpresion := conditionCode = true storeString.
	"defaultConfigurationExpresion 
		ifFalse: [emParentApp addConfigurationExpression: conditionCode ]."
	newSubApp := emParentApp createSubApplication: self identifier in: true storeString
	"defaultConfigurationExpresion ifFalse: [
		newSubApp configurationExpression: conditionCode ]"

]

{ #category : 'loading' }
TonelLoaderSubApplication >> createSubApplicationsFor: emAppOrSubapp withRoot: emRootApp [

	self loader subapplicationsStrategy createSubApplicationsFor: self in: emAppOrSubapp withRoot: emRootApp

	
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> definedClasses [
	"Answer the collection classes defined in the receiver that are not shared pools."

	^self packageDefinedClasses reject: [:each | each isSharedPool]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> definedSharedPools [
	"Answer the collection of shared pools defined by the receiver."

	^self packageDefinedClasses select: [:each | each isSharedPool]
]

{ #category : 'loading' }
TonelLoaderSubApplication >> definePoolDictionariesFor: emParentApp [

	| theApp |

	theApp := Smalltalk classAt: self identifier.
	self
		definePoolDictionariesForClassesIn: theApp;
		definePoolDictionariesInSubApplicationsFor: theApp
]

{ #category : 'loading' }
TonelLoaderSubApplication >> definePoolDictionariesForClassesIn: anApp [

	| definedSharedPools |

	(definedSharedPools := self definedSharedPools).

	(self definedClasses select: [:each | (self emApplication notNil and: [each identifier = self emApplication name]) or: [each identifier = self identifier]]) collect: [
		:tonelClass |
		tonelClass loadDeclarationMethodsInto: anApp using: self loader.
		EmInterface current rebuildNamespaceFor: self emApplication
	].

	definedSharedPools notEmpty
		ifTrue: [
			definedSharedPools
				do: [:aTonelClass | aTonelClass declarePoolDictionariesIn: anApp using: self loader].
			self updateSharedPoolsDefinitionOf: anApp.
			definedSharedPools
				do: [:aTonelClass | aTonelClass definePoolDictionariesIn: anApp using: self loader].
			self updateSharedPoolsDefinitionOf: anApp]
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

{ #category : 'testing' }
TonelLoaderSubApplication >> do: aBlock forApp: app withSuperUser: user [

	^TonelLoader do: aBlock forApp: app withSuperUser: user
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> emApplication [
	"Answer the actual Application/SubApplication instance of receiver, or nil if there is none."

	^emApplication
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> emApplication: emAppOrSubApp [
	"Sets the Application/SubApplication instance of receiver."

	emApplication := emAppOrSubApp
]

{ #category : 'querying' }
TonelLoaderSubApplication >> emClass [
	"Answers the ENVY/Manager class for receiver."

	^SubApplication
]

{ #category : 'querying' }
TonelLoaderSubApplication >> hasChangesFor: emAppOrSubApp inRootApp: emRootApplication [
	"Answer whether receiver has changes for anAppOrSubApp 
	 in the three of emRootApplication <Application>."

	^hasChanges
		ifNil: [hasChanges := self computeHasChangesFor: emAppOrSubApp inRootApp: emRootApplication]
]

{ #category : 'testing' }
TonelLoaderSubApplication >> hasChangesIn: emParentApp [
	"Answer whether receiver has changes for anAppOrSubApp,
	 as a subApplication of emParentApp (<Application> or <SubApplication)."

	^(Smalltalk classAt: self identifier)
		ifNil: [true]
		ifNotNil: [:emSubApp | self hasChangesFor: emSubApp inRootApp: emParentApp]
]

{ #category : 'querying' }
TonelLoaderSubApplication >> hasClassChangesComparedTo: emAppOrSubApp [
	"Answer whether receiver has changes compared 
	 to emAppOrSubApp (<Application> or <SubApplication>)."

	^self tonelDefinedClasses , self tonelExtendedClasses
		anySatisfy: [:tonelClass | tonelClass hasChangesIn: emAppOrSubApp]
]

{ #category : 'querying' }
TonelLoaderSubApplication >> hasRemovedClassesFor: anAppOrSubApp [
	"Answer whether receiver removes any class from anAppOrSubApp."

	^(self hasRemovedDefinedClassesFor: anAppOrSubApp)
		or: [self hasRemovedExtendedClassesFor: anAppOrSubApp]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> hasRemovedDefinedClassesFor: emAppOrSubApp [
	^emAppOrSubApp defined anySatisfy: [:definedClass |
		(definedClass ~= emAppOrSubApp) and: [
			(self definedClasses anySatisfy: [:each | each name asString = definedClass name asString]) not]]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> hasRemovedExtendedClassesFor: anApp [
	^anApp extended anySatisfy: [:extendedClass |
		(self tonelExtendedClasses includesKey: extendedClass name) not]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> identifier [
	"Answer the symbol identifer of receiver."

	^self name asSymbol
]

{ #category : 'testing' }
TonelLoaderSubApplication >> includesClassNamed: aSymbol [
	"Answer whether receiver includes a class, either defined or extended, 
	 named aSymbol."

	^self tonelClasses includesKey: aSymbol
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
	"Initializes the subapplications of receiver."

	self initializeSubApplicationsWithRoot: self rootTonelApplication
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> initializeSubApplicationsWithRoot: rootTonelApplication [
	"Forces the initalization and lookup of receiver sub applications."

	subApplications := (self loader subapplicationsStrategy subApplicationsOf: self withRoot: rootTonelApplication) asOrderedCollection
]

{ #category : 'testing' }
TonelLoaderSubApplication >> isApplication [
	"Answer whether receiver is anApplication."

	^false
]

{ #category : 'querying' }
TonelLoaderSubApplication >> loadableConditions [
	"Answer the load conditions of receiver that evaluate to true."

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
	"Loads the base edition of receiver."

	self loader loadBaseEditionFor: self
	
]

{ #category : 'loading' }
TonelLoaderSubApplication >> loadClassesIn: anApp using: aLoader [

	| sortedClasses |
	sortedClasses := self 
				topologicallySort: (self tonelClasses reject: [:each1 | each1 isSharedPool])
				in: anApp.
	aLoader createsHookMethods 
		ifTrue: [self loadHookMethodsFor: anApp using: aLoader].
	sortedClasses do: [:each | each key loadInto: anApp using: aLoader]
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> loader [

	^loader
]

{ #category : 'loading' }
TonelLoaderSubApplication >> loadFor: tonelApp inRootApp: rootApp using: aLoader [

	| theApp |

	theApp := Smalltalk at: self identifier.
	(theApp isNil or: [aLoader alwaysCreateEditions or: [self hasChangesFor: theApp inRootApp: rootApp]])
		ifTrue: [
			self
				loadClassesIn: theApp using: aLoader;
				loadSubApplicationsOf: theApp inRootApp: rootApp using: aLoader;
				removeDeletedSubApplicationsFor: theApp;
				versionClassesIn: theApp using: aLoader
						"version: theApp as: aLoader versionName"
						]
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> loadHookMethodsFor: anApp using: aLoader [

	| appClass |
	appClass := Smalltalk at: anApp name.
	(TonelReaderMethodDefinition loadedMethodFor: appClass name) 
		loadFor: appClass
		into: appClass
		using: aLoader.
	(TonelReaderMethodDefinition removingMethodFor: appClass name) 
		loadFor: appClass
		into: appClass
		using: aLoader.
	(TonelReaderMethodDefinition failedRemoveMethodFor: appClass name) 
		loadFor: appClass
		into: appClass
		using: aLoader
]

{ #category : 'loading' }
TonelLoaderSubApplication >> loadSubApplicationsOf: anApp inRootApp: rootApp using: aLoader [

	self subApplications do: 
			[:tonelSubApp | 
			tonelSubApp 
				loadFor: self
				inRootApp: rootApp
				using: aLoader]
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
	^name ifNil: [name := self computeName]
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> name: aString [

	name := aString
]

{ #category : 'accessing' }
TonelLoaderSubApplication >> notes [
		
	^self rootTonelApplication notes
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> notifyLoaded [

	self notifyLoadedClasses.
	self notifyLoadedApps.
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> notifyLoadedApps [

	| theApp |
	theApp := Smalltalk classAt: self identifier.
	(theApp class includesSelector: #loaded) ifTrue: [theApp loaded].
	self subApplications do: [:each | each notifyLoadedApps]
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoaderSubApplication >> notifyLoadedClasses [

	| theApp |

	self subApplications do: [:each | each notifyLoadedClasses].
	theApp := Smalltalk classAt: self identifier.
	self definedClasses do: [:each |
		(each concreteClassIn: theApp rootApplication) ifNotNil: [:class |
			(class includesSelector: #initializeAfterLoad) ifTrue: [class initializeAfterLoad]]]
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
	aClassDefinition superclassIdentifier isNil ifTrue: [^nil].
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
TonelLoaderSubApplication >> subApplicationsHaveChangesFor: emAppOrSubApp inRootApp: emRootApp [

	^(self subApplications 
		anySatisfy: [:aTonelSubApp | aTonelSubApp hasChangesIn: emRootApp]) 
			or: 
				[emAppOrSubApp subApplications anySatisfy: 
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
		keysDo: [:key | definedClasses at: key name asSymbol put: key].
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
TonelLoaderSubApplication >> versionClassesIn: anApp using: aLoader [

	(self tonelClasses reject: [:each | each isSharedPool]) do: [:aTonelClass | aTonelClass versionIn: anApp using: aLoader]
]

{ #category : 'versioning' }
TonelLoaderSubApplication >> versionUsing: aLoader [

	| theApp |

	theApp := Smalltalk classAt: self identifier.
	self subApplications do: [:aTonelSubApp | aTonelSubApp versionUsing: aLoader].
	theApp isEdition ifFalse: [^self].

	self versionClassesIn: theApp using: aLoader.

	(theApp isEditionIn: theApp)
		ifTrue: [
			theApp versionNameIn: theApp is: aLoader versionName.
			(theApp isVersionIn: theApp)
				ifTrue: [
					TonelLoader
						do: [theApp releaseClass: theApp]
						forApp: theApp
						withSuperUser: theApp manager]].
	theApp isEdition
		ifTrue: [
			self
				do: [self version: theApp as: aLoader versionName]
				forApp: theApp
				withSuperUser: theApp manager]


]

{ #category : 'accessing' }
TonelLoaderSubApplication >> withAllSubApplications [
		"Return the receiver with all its sub-applications."

	| answer |
	answer := OrderedCollection with: self.
	self addAllSubApplicationsTo: answer.
	^answer
]
