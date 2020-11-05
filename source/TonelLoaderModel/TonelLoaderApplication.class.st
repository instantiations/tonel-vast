Class {
	#name : 'TonelLoaderApplication',
	#superclass : 'TonelLoaderSubApplication',
	#instVars : [
		'dependents',
		'notes'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'configuring' }
TonelLoaderApplication >> accountForPoolDictionaryClasses [
	"Add 'Pool' to the keys of any pool dictionary classes (by removing
	  those classes from the list, then adding them with the new key)"

	| poolClasses |

	poolClasses := self tonelDefinedClasses select: [:tonelClass | tonelClass isSharedPool].
	self tonelDefinedClasses removeAllKeys: poolClasses keys.
	poolClasses do: [:tonelClass | self tonelDefinedClasses at: (tonelClass name) put: tonelClass]



]

{ #category : 'configuring' }
TonelLoaderApplication >> addPrerequisite: aClass [


	super addPrerequisite: aClass 
]

{ #category : 'querying' }
TonelLoaderApplication >> allDefinedClassNames [
	
	^self allDefinedClasses keys
]

{ #category : 'querying' }
TonelLoaderApplication >> allDependentApplications [
	"Return the complete set of applications which are dependent
	 on the receiver starting with its direct dependents. Sort them
	 alphabetically; then add all of their dependents (sorted
	 alphabetically and so on). No dependent may appear before
	 one of its prerequisites."

	| result new |

	result := OrderedCollection new.
	new := self dependentApplications.
	[ new isEmpty ] whileFalse: [ | temp |
		temp := Set new.
		new do: [ :app |
			result remove: app ifAbsent: [ ].
			app dependentApplications do: [ :dep |
				temp add: dep ] ].
		result addAll: new. "make them be at the end"
		new := temp asSortedCollection: Class sortBlock ].
	^ result
]

{ #category : 'accessing' }
TonelLoaderApplication >> allPrerequisites [
		"Return all the TonelLoaderApplications which the receiver is dependent on,
		 starting with its direct prerequisites. Sort them alphabetically;
		 then add all of their prerequisites (sorted alphabetically and
		 so on). No prereq may appear before one of its dependents."

	| result new temp |
	result := OrderedCollection new.
	new := self prerequisites.
	[new isEmpty] whileFalse: [
		temp := Set new.
		new do: [:app |
			result remove: app ifAbsent: [].
			app prerequisites do: [:prereq |
				temp add: prereq]].
		result addAll: new. "make them be at the end"
		new := temp asSortedCollection: Class sortBlock].
	^result
]

{ #category : 'accessing' }
TonelLoaderApplication >> asSymbol [
	
	^self identifier
]

{ #category : 'querying' }
TonelLoaderApplication >> availableShadows [
	^Application shadowsFor: self name
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderApplication >> computeImplicitPrerequisites [

	| needed  |
	needed := Set new.
	self withAllSubApplications do: [:app |
		app tonelDefinedClasses do: [:cl |
			((cl tonelSuperclassIn: self loader)) ifNotNil: [:itsSuper  |
				needed add: (itsSuper rootTonelApplicationIn: self loader)]].
		app tonelExtendedClasses do: [:cl |
			 (cl rootTonelApplicationIn: self loader) ifNotNil: [:itsSuper |	needed add: itsSuper ]].
		(app tonelDefinedClasses, app tonelExtendedClasses) asArray do: [:cl |
			(cl tonelMethods) do: [:cm |
				(cm referencedTonelClasses: self loader) do: [:referencedClass |
					needed add: (referencedClass rootTonelApplicationIn: self loader)]]]].

	needed remove: self ifAbsent: [].
	needed copy do: [:app |
		app allPrerequisites do: [:prereq |
			needed remove: prereq ifAbsent: []]].
	^needed
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderApplication >> computeName [
	^self loader namingStrategy nameForApp: self
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderApplication >> computePrerequisites [

	^(self packageDefinition metadata
		at: #vaPrerequisites
		ifAbsent: [self computeImplicitPrerequisites])
			asOrderedCollection
				collect: [:each |
					Smalltalk
						at: each asSymbol
						ifAbsent: [
							Application shadowClass
								named: each asSymbol
								timeStamp: EmTimeStamp undefined]]
]

{ #category : 'accessing' }
TonelLoaderApplication >> concretePrerequisites [
	"Reduce the collection of prerequisite Applications to only
	 those that are immediate prerequisites of the receiver."

	^ self prerequisiteApps reject: [ :eachApp |
		self prerequisiteApps anySatisfy: [ :checkApp |
			(eachApp = checkApp) not and: [
				checkApp withAllPrerequisites includes: eachApp ] ] ]
]

{ #category : 'loading' }
TonelLoaderApplication >> create [
	"Create (or modify) a real Application from the receiver."

	(self loader alwaysCreateEditions or: [self hasChanges])
		ifTrue: [
			self loadPrerequisites.
			emApplication := self createEdition.
			"If prerequisites are not set it wont be able to load classes"

			self
				do: [
					emApplication prerequisites: self prerequisites.
					self
						createTonelPackageNameMethodFor: emApplication;
						createDescriptionFor: emApplication;
						createSubApplicationsFor: emApplication withRoot: emApplication]
				forApp: emApplication
				withSuperUser: emApplication manager]
		ifFalse: [emApplication := (Smalltalk at: self identifier)]
]

{ #category : 'loading' }
TonelLoaderApplication >> createApplication [
	"Create a real Application based on the receiver."
	
	Application
		create: self identifier
		with: self concretePrerequisites
]

{ #category : 'loading' }
TonelLoaderApplication >> createEdition [

	| theApp |

	(Smalltalk classAt: self identifier ifAbsent: []) ifNil: [
		(self loader hasSelectableBaseEditionFor: self)
			ifTrue: [self loadBaseEdition]
			ifFalse: [self createApplication]].
	theApp := Smalltalk classAt: self identifier.

	self
		do: [
			theApp isEdition ifFalse: [(theApp newEdition)].
			]
		forApp: theApp
		withSuperUser: theApp manager.
	self changeCurrentUserAndSuperGroupSettingOf: theApp.
	^theApp
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelLoaderApplication >> createTonelPackageNameMethodFor: anApp [
	"Enter the new method definition below and click 'Resume'."

	| source |
	(anApp respondsTo: self tonelPackageNameSelector)
		ifTrue: [| tonelPackageName |
			tonelPackageName := anApp perform: self tonelPackageNameSelector.
			self packageName = tonelPackageName ifTrue: [^self]].
	source := self tonelPackageNameMethodSource.
	(anApp class basicCompile: source notifying: Transcript ifFail: []) ifNotNil: [:compiledMethod |
		anApp class
			install: compiledMethod
			asPrivate: true
			withSource: source
			ifNewAddTo: anApp
			categorizeIn: #('Tonel-Metadata')] "Have it notify itself?"
]

{ #category : 'loading' }
TonelLoaderApplication >> definePoolDictionaries [

	self hasChanges
		ifTrue: [ | anApp |
			anApp :=Smalltalk classAt: self identifier.
			self updateSharedPoolsDefinitionOf: anApp.
			self 
				definePoolDictionariesForClassesIn: anApp;
				definePoolDictionariesInSubApplicationsFor: anApp]
]

{ #category : 'querying' }
TonelLoaderApplication >> dependentApplications [

	^dependents ifNil: [dependents := OrderedCollection new]
]

{ #category : 'testing' }
TonelLoaderApplication >> hasChanges [
	"Answer true if anything within the application has changed based on
	 this import; otherwise answer false."

	^hasChanges ifNil: [
		"self poolsAccounted ifFalse: [ self accountForPoolDictionaryClasses ]."
		self loadBaseApplication.
		emApplication := Smalltalk classAt: self identifier.
		hasChanges :=
			emApplication isNil or: [
				(self hasClassChangesComparedTo: emApplication) or: [
					(self hasRemovedClassesFor: emApplication) or: [
						self subApplicationsHaveChangesFor: emApplication inRootApp: emApplication]]]]
]

{ #category : 'loading' }
TonelLoaderApplication >> loadBaseApplication [
	"If the real application represented by the receiver is not currently loaded,
	 and if it already exists, then load it."
	 
	Smalltalk classAt: self identifier ifAbsent: [
		(self loader hasSelectableBaseEditionFor: self)
			ifTrue: [self loadBaseEdition ] ]
]

{ #category : 'loading' }
TonelLoaderApplication >> loadPrerequisites [


	self prerequisiteApps do: [:each |
		(self prerequisiteIsLoaded: each)
			ifFalse: [
				(self loader baseEditionStrategy selectPrerequisiteEditionOf: each)
					ifNil: [
						(self loader applicationNamed: each name asString ifNone: [nil])
							ifNil: [TonelLoaderError signal: (TonelMsg18 bindWith: self name)]
							ifNotNil: [:tonelApplication |
								self loader basicLoadApplication: tonelApplication]]
					ifNotNil: [:prereqEdition |
						(EmImageBuilder loadApplications: (
							self loader baseEditionStrategy
								findAllApplicationsToLoadWith: (Array with: prereqEdition)))
									ifNil: [
										TonelLoaderError signal: (TonelMsg18 bindWith: self name) "$NLS$ Could not load base edition of %1. Load aborted."]]]]



]

{ #category : 'accessing' }
TonelLoaderApplication >> notes [
	^notes ifNil: [notes := String new]
]

{ #category : 'accessing' }
TonelLoaderApplication >> notes: anObject [
	notes := anObject
]

{ #category : 'accessing' }
TonelLoaderApplication >> poolsAccounted [

	^poolsAccounted ifNil: [poolsAccounted := false]
]

{ #category : 'accessing' }
TonelLoaderApplication >> prerequisiteApps [
	"Answer a collection of real Applications that are prerequisites of
	 the receiver."

	^self prerequisites collect: [:eachPrereq |
		eachPrereq class = TonelLoaderApplication
			ifTrue: [Smalltalk classAt: eachPrereq identifier]
			ifFalse: [eachPrereq]]
]

{ #category : 'testing' }
TonelLoaderApplication >> prerequisiteIsLoaded: emShadow [

	^emShadow isLoaded
		or: [self loader loadedApplicationsIdentifiers includes: emShadow name asString]
]

{ #category : 'accessing' }
TonelLoaderApplication >> prerequisites: anOrderedCollection [

	prerequisites := anOrderedCollection
]

{ #category : 'loading' }
TonelLoaderApplication >> replacePrerequisite: anApplication [

	
	self prerequisites keysAndValuesDo: [:index :each |
		each name = anApplication name
			ifTrue: [
				self prerequisites at: index put: anApplication
			]
	]
]

{ #category : 'accessing' }
TonelLoaderApplication >> rootTonelApplication [
	"The receiver is the root application."
	
	^self
]

{ #category : 'loading' }
TonelLoaderApplication >> tonelPackageNameMethodSource [
	^self tonelPackageNameSelector , '<n><t>^<1p>' 
		expandMacrosWith: self packageName
]

{ #category : 'loading' }
TonelLoaderApplication >> tonelPackageNameSelector [
	^#_TONEL_packageName
]

{ #category : 'accessing' }
TonelLoaderApplication >> tonelPoolDictionaries [
	
	^self tonelDefinedClasses select: [:each | each isSharedPool ]
]

{ #category : 'validating' }
TonelLoaderApplication >> verifyBaseEditionUser [

	(Smalltalk classAt: self identifier) ifNotNil: [:theApp |
		(theApp manager = EmUser current or: [(self loader hasSuperGroupAccessTo: theApp)])
			ifFalse: [
				self halt: (
					TonelMsg09
						bindWith: self name
						with: theApp manager uniqueName
						with: EmUser current uniqueName)]] "$NLS$ Base edition for %1 is managed by %2. You are currently %3 and cannot create new editions of the application."
]
