Class {
	#name : 'TonelLoaderApplication',
	#superclass : 'TonelLoaderSubApplication',
	#instVars : [
		'dependents',
		'notes'
	],
	#category : 'TonelLoaderModel'
}

{
	#category : 'configuring'
}
TonelLoaderApplication >> accountForPoolDictionaryClasses [
	"Add 'Pool' to the keys of any pool dictionary classes (by removing
	  those classes from the list, then adding them with the new key)"

	| poolClasses |

	poolClasses := self tonelDefinedClasses select: [:tonelClass | tonelClass isSharedPool].
	self tonelDefinedClasses removeAllKeys: poolClasses keys.
	poolClasses do: [:tonelClass | self tonelDefinedClasses at: (tonelClass name) put: tonelClass]



]

{
	#category : 'configuring'
}
TonelLoaderApplication >> addPrerequisite: aClass [


	super addPrerequisite: aClass 
]

{
	#category : 'querying'
}
TonelLoaderApplication >> allDefinedClassNames [
	
	^self allDefinedClasses keys
]

{
	#category : 'querying'
}
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

{
	#category : 'querying'
}
TonelLoaderApplication >> availableShadows [
	^Application shadowsFor: self name
]

{
	#category : 'configuring'
}
TonelLoaderApplication >> changeSuperGroupSettingOf: aClass [

	
	super changeSuperGroupSettingOf: aClass
]

{
	#category : 'initializing',
	#vaVisibility : 'private'
}
TonelLoaderApplication >> computePrerequisites [

	^(self packageDefinition metadata at: #vaPrerequisites ifAbsent: [#()]) asOrderedCollection
		collect: [:each |
			Smalltalk
				at: each asSymbol
				ifAbsent: [
					Application shadowClass named: each asSymbol timeStamp: EmTimeStamp undefined]]
]

{
	#category : 'accessing'
}
TonelLoaderApplication >> concretePrerequisites [
	"Reduce the collection of prerequisite Applications to only
	 those that are immediate prerequisites of the receiver."

	^ self prerequisiteApps reject: [ :eachApp |
		self prerequisiteApps anySatisfy: [ :checkApp |
			(eachApp = checkApp) not and: [
				checkApp withAllPrerequisites includes: eachApp ] ] ]
]

{
	#category : 'loading'
}
TonelLoaderApplication >> create [
	"Create (or modify) a real Application from the receiver."

	self hasChanges 
		ifTrue: 
			[| theApp |
			theApp := self createEdition.
			"If prerequisites are not set it wont be able to load classes"
			theApp prerequisites: self prerequisites.
			self
				createDescriptionFor: theApp;
				createSubApplicationsFor: theApp withRoot: theApp]
]

{
	#category : 'loading'
}
TonelLoaderApplication >> createApplication [
	"Create a real Application based on the receiver."
	
	Application
		create: self identifier
		with: self concretePrerequisites
]

{
	#category : 'loading'
}
TonelLoaderApplication >> createDescriptionFor: aClass [

	
	super createDescriptionFor: aClass
]

{
	#category : 'loading'
}
TonelLoaderApplication >> createEdition [
	| theApp |
	
	(Smalltalk classAt: self identifier ifAbsent: []) 
		ifNil: [
			(Application allNamesWithoutPackages includes: self identifier)
				ifTrue: [self loadBaseEdition]
				ifFalse: [self createApplication]].
	theApp := Smalltalk classAt: self identifier.
	theApp isEdition ifFalse: [theApp newEdition].
	self changeCurrentUserAndSuperGroupSettingOf: theApp.
	^theApp
]

{
	#category : 'loading'
}
TonelLoaderApplication >> definePoolDictionaries [
	self hasChanges
		ifTrue: [ | theApp |
			theApp :=Smalltalk classAt: self identifier.
			self 
				definePoolDictionariesForClassesIn: theApp;
				definePoolDictionariesInSubApplicationsFor: theApp]
]

{
	#category : 'querying'
}
TonelLoaderApplication >> dependentApplications [

	^dependents ifNil: [dependents := OrderedCollection new]
]

{
	#category : 'testing'
}
TonelLoaderApplication >> hasChanges [
	"Answer true if anything within the application has changed based on
	 this import; otherwise answer false."

	^hasChanges ifNil: 
			[| theApp |
			#toDo.
			"self poolsAccounted ifFalse: [ self accountForPoolDictionaryClasses ]."
			self loadBaseApplication.
			theApp := Smalltalk classAt: self identifier.
			hasChanges := theApp isNil or: 
							[(self tonelDefinedClasses 
								anySatisfy: [:class | class hasChangesIn: theApp]) or: 
										[(self hasRemovedClassesFor: theApp) 
											or: [self subApplicationsHaveChangesFor: theApp inRootApp: nil]]]]
]

{
	#category : 'loading'
}
TonelLoaderApplication >> loadBaseApplication [
	"If the real application represented by the receiver is not currently loaded,
	 and if it already exists, then load it."
	 
	Smalltalk classAt: self identifier ifAbsent: [
		(Application allNamesWithoutPackages includes: self identifier)
			ifTrue: [self loadBaseEdition ] ]
]

{
	#category : 'accessing'
}
TonelLoaderApplication >> notes [
	^notes ifNil: [notes := String new]
]

{
	#category : 'accessing'
}
TonelLoaderApplication >> notes: anObject [
	notes := anObject
]

{
	#category : 'accessing'
}
TonelLoaderApplication >> poolsAccounted [

	^poolsAccounted ifNil: [poolsAccounted := false]
]

{
	#category : 'accessing'
}
TonelLoaderApplication >> prerequisiteApps [
	"Answer a collection of real Applications that are prerequisites of
	 the receiver."

	^self prerequisites collect: [:eachPrereq |
		eachPrereq class = TonelLoaderApplication
			ifTrue: [Smalltalk classAt: eachPrereq identifier]
			ifFalse: [eachPrereq]]
]

{
	#category : 'accessing'
}
TonelLoaderApplication >> prerequisites: anOrderedCollection [

	prerequisites := anOrderedCollection
]

{
	#category : 'accessing'
}
TonelLoaderApplication >> rootTonelApplication [
	"The receiver is the root application."
	
	^self
]

{
	#category : 'accessing'
}
TonelLoaderApplication >> tonelPoolDictionaries [
	
	^self tonelDefinedClasses select: [:each | each isSharedPool ]
]

{
	#category : 'validating'
}
TonelLoaderApplication >> verifyBaseEditionUser [

	(Smalltalk classAt: self identifier) ifNotNil: [:theApp |
		theApp manager = EmUser current
			ifFalse: [
				self halt: (
					TonelMsg09
						bindWith: self name
						with: theApp manager uniqueName
						with: EmUser current uniqueName)]] "$NLS$ Base edition for %1 is managed by %2. You are currently %3 and cannot create new editions of the application."
]
