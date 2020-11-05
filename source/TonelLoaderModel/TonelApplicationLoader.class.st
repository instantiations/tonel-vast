Class {
	#name : 'TonelApplicationLoader',
	#superclass : 'Object',
	#instVars : [
		'tonelApplication',
		'loader',
		'versionName'
	],
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelApplicationLoader class >> on: aTonelApplication in: aTonelLoader [

	^self new
		setTonelApplication: aTonelApplication loader: aTonelLoader;
		yourself
]

{ #category : 'loading-internal' }
TonelApplicationLoader >> allClassesWithAssociation [
	^self tonelApplication allClassesWithAssociation 
		tonelSingleEdgeTopologicallySortedCollection 
			reject: [:each | each key isSharedPool]
]

{ #category : 'testing' }
TonelApplicationLoader >> alwaysCreateEditions [

	^self loader alwaysCreateEditions
]

{ #category : 'loading-internal' }
TonelApplicationLoader >> autogenerateClassSideNewInitializers [

	| allDefinedClasses superclasses |

	allDefinedClasses := tonelApplication allDefinedClasses.
	superclasses := self detectAllRootSuperclassesWithinApp.
	superclasses do: [:aSuperclass | | tonelClass |
		tonelClass := allDefinedClasses at: aSuperclass.
		"Only generate #new if it does not have it...we don't want to override it"
		tonelClass includesClassSideNewMethod
			ifFalse: [
				tonelClass addMethod: (TonelReaderMethodDefinition newInitializeMethodFor: aSuperclass)]]
]

{ #category : 'loading-internal' }
TonelApplicationLoader >> checkClassExtensions [

	self tonelApplication checkClassExtensionsExcepting: self tonelApplication allDefinedClassNames
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> checkForUnloadedApplication [

	Smalltalk classAt: self tonelApplication identifier ifAbsent: [
		(self loader hasSelectableBaseEditionFor: self tonelApplication)
			ifTrue: [self loader loadBaseEditionFor: self tonelApplication ] ]
]

{ #category : 'loading-internal' }
TonelApplicationLoader >> checkSuperclasses [

	self tonelApplication checkSuperclassesExcepting: self tonelApplication allDefinedClasses
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> checkThatUserCanModifyApplication [

	self tonelApplication verifyBaseEditionUser
]

{ #category : 'loading-prompters',
  #vaVisibility : 'private' }
TonelApplicationLoader >> choosePrerequisites [
	self tonelApplication prerequisites: self computePrerequisites
]

{ #category : 'loading-prompters',
  #vaVisibility : 'private' }
TonelApplicationLoader >> chooseVersionName [

	self versionName: (self loader versionFor: self tonelApplication)
	
]

{ #category : 'loading-prompters' }
TonelApplicationLoader >> computePrerequisites [
	^self loader prerequisitesFor: self tonelApplication current:  tonelApplication prerequisites
]

{ #category : 'loading-internal' }
TonelApplicationLoader >> convertSharedPoolClasses [
	"Enter the new method definition below and click 'Resume'."
	
	self tonelApplication convertSharedPoolClasses
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> createAndLoadApplication [
	"The contents of the Monticello file has been parsed and converted to classes representing
	 the content. Now process those classes to create real classes in the application."

	self
		chooseVersionName;
		createApplication.

	self tonelApplication emApplication isEdition ifFalse: [^self].
	self
		definePoolDictionaries;
		createClasses;
		prepareRemovedClasses;
		updateClassDefinitions;
		deleteRemovedClasses;
		loadApplication;
		deleteRemovedSubApplications;
		versionApplication;
		markAsLoaded


]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> createApplication [

	self tonelApplication create
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> createClasses [
	self allClassesWithAssociation 
		do: [:ea | ea key createEditionIn: ea value using: self]
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> createTonelMetadataMethods [

	self tonelApplication createTonelMetadataMethods
]

{ #category : 'querying' }
TonelApplicationLoader >> definedClasses [

	^self tonelApplication definedClasses
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> definePoolDictionaries [

	self tonelApplication definePoolDictionaries
]

{ #category : 'querying' }
TonelApplicationLoader >> deletedClasses [

	^ self tonelApplication allClassesToRemoveIncludingExtensions: true
]

{ #category : 'loading-internal' }
TonelApplicationLoader >> deletedDefinedClasses [

	^ self tonelApplication allClassesToRemoveIncludingExtensions: false
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> deleteRemovedClasses [

	self deletedClasses tonelSingleEdgeTopologicallySortedCollection reverseDo: [ :ea |
		ea value deleteClasses: (Array with: ea key) ]
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> deleteRemovedSubApplications [

	self tonelApplication deleteRemovedSubApplications
]

{ #category : 'querying' }
TonelApplicationLoader >> detectAllRootSuperclassesWithinApp [

	| superclasses allDefinedClasses superclassBlock |

	allDefinedClasses := tonelApplication allDefinedClasses.
	superclasses := Set new.
	allDefinedClasses keysAndValuesDo: [:aClassName :tonelClass |
		superclassBlock := [:aClass |
			(allDefinedClasses includesKey: aClass superclassIdentifier asString)
				ifTrue: [
					superclassBlock
						value: (allDefinedClasses at: aClass superclassIdentifier asString)]
				ifFalse: [aClass name]].
		superclasses add: (superclassBlock value: tonelClass)].
	^superclasses
]

{ #category : 'testing' }
TonelApplicationLoader >> hasVersionName [

	^self versionName isEmptyOrNil not
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelApplicationLoader >> initialize [

	super initialize.
	versionName := String new.
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> initializeApplication [

	self tonelApplication initialize
]

{ #category : 'loading' }
TonelApplicationLoader >> load [

	self loader log: (TonelMsg20 expandMacrosWith: self tonelApplication name).
	"self autogenerateClassSideNewInitializers."
	[
		self
			convertSharedPoolClasses;
			checkClassExtensions;
			checkSuperclasses;
			checkForUnloadedApplication;
			checkThatUserCanModifyApplication;
			choosePrerequisites;
			createAndLoadApplication]
				on: TonelLoaderError
				do: [:ex | ex pass]
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> loadApplication [

	self tonelApplication loadUsing: self
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelApplicationLoader >> loader [

	^loader
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelApplicationLoader >> markAsLoaded [

	self tonelApplication notifyLoad.
	self loader addLoadedApplication: self tonelApplication
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> prepareRemovedClasses [

	EmClassCreator waitForMultipleChanges.
	self deletedDefinedClasses do: [ :ea | | eaClass methods |
		eaClass := ea key.
		"Remove the defined variables (in case a superclass will be defining
		  those variables as part of the load)"
		eaClass creatorClass
			createClassNamed: eaClass environmentKey
			in: eaClass environment
			for: (eaClass hasController ifTrue: [ eaClass controller ] ifFalse: [ nil ])
			subclassOf: eaClass superclass
			instanceShape: eaClass instanceShape
			classInstanceVariables: ''  "$NON-NLS$"
			instanceVariables: ''  "$NON-NLS$"
			classVariables: ''  "$NON-NLS$"
			sharedPoolNames: #().
		"Remove any pool dictionary definition methods (in case any other
		  class will be defining that pool as part of the load)"
		methods := OrderedCollection new.
		eaClass class methodDictionary do: [ :eachMethod |
			('_PRAGMA_*' match: eachMethod selector asString)	"$NON-NLS$"
				ifTrue: [ methods add: eachMethod ] ]. 
		EmInterface current removeMethods: methods asArray ].
	EmClassCreator finishedMultipleChanges
]

{ #category : 'accessing' }
TonelApplicationLoader >> rootTonelApplication [
	"Enter the new method definition below and click 'Resume'."
	self halt
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelApplicationLoader >> setTonelApplication: aTonelApplication loader: aTonelLoader [

	tonelApplication := aTonelApplication.
	loader  := aTonelLoader
]

{ #category : 'accessing' }
TonelApplicationLoader >> tonelApplication [

	^tonelApplication
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> updateClassDefinitions [

	EmClassCreator waitForMultipleChanges.
	self allClassesWithAssociation do: [:ea | ea key extension ifFalse: [ ea key updateVariables ]].
	EmClassCreator finishedMultipleChanges
]

{ #category : 'loading-internal',
  #vaVisibility : 'private' }
TonelApplicationLoader >> versionApplication [

	self tonelApplication versionUsing: self
]

{ #category : 'accessing' }
TonelApplicationLoader >> versionName [

	^versionName ifNil: [versionName := String new]
]

{ #category : 'accessing' }
TonelApplicationLoader >> versionName: aVersionNameOrNil [

	
	versionName := aVersionNameOrNil
]
