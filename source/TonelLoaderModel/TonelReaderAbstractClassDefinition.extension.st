Extension {
	#name : 'TonelReaderAbstractClassDefinition'
}

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> concreteClassIn: anApp [

	self subclassResponsibility 
]

{ #category : 'loading-changes',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> deleteRemovedClassMethodsFrom: aClass in: anApp [

	| methodsToRemove |
	methodsToRemove := aClass class methodDictionary values select: 
					[:compiledMethod | 
					compiledMethod application = anApp and: 
							[self tonelMethods noneSatisfy: 
									[:anMCMethod | 
									anMCMethod isClassSide 
										and: [compiledMethod selector = anMCMethod selector]]]].
	methodsToRemove := methodsToRemove 
				reject: [:each | self isArtificiallyCreatedMethod: each inApp: anApp].
	methodsToRemove 
		do: [:compiledMethod | self removeCompiledMethod: compiledMethod from: anApp]
]

{ #category : 'loading-changes',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> deleteRemovedInstanceMethodsFrom: aClass in: anApp [

	aClass methodDictionary do: 
			[:compiledMethod | 
			(compiledMethod application = anApp and: 
					[self tonelMethods noneSatisfy: 
							[:anMCMethod | 
							anMCMethod isClassSide not 
								and: [compiledMethod selector = anMCMethod selector]]]) 
				ifTrue: [self removeCompiledMethod: compiledMethod from: anApp]]
]

{ #category : 'loading-changes',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> deleteRemovedMethodsFrom: anApp using: aLoader [

	(self concreteClassIn: anApp)
		ifNil: [
			self isSharedPool
				ifFalse: [self error: ('Cannot find the concrete app for <1p>' expandMacrosWith: self name)]
		]
		ifNotNil: [:concreteClass |
			self
				deleteRemovedInstanceMethodsFrom: concreteClass in: anApp;
				deleteRemovedClassMethodsFrom: concreteClass in: anApp]

]

{ #category : 'testing' }
TonelReaderAbstractClassDefinition >> hasChangesIn: emAppOrSubApp [
	"Answer whether receiver has changes considering it was 
	 defined in emAppOrSubApp."

	hasChanges isNil
		ifTrue: [| baseClass |
			self isSharedPool
				ifTrue: [
					hasChanges :=
						(tonelMethods select: [:each | each isDeclaration])
							anySatisfy: [:tonelMethod | tonelMethod hasChangesIn: emAppOrSubApp]

					]
				ifFalse: [
					hasChanges :=
						(baseClass := self concreteClassIn: emAppOrSubApp) isNil
							or: [self hasChangesIn: emAppOrSubApp comparedTo: baseClass]]].
	^hasChanges
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> hasChangesIn: anApp comparedTo: aClass [

	self subclassResponsibility
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> hasClassMethodsRemovedFrom: aClass in: anApp [
	"Answer whether receiver has class methods removed from aClass
	 as defined in anApp."

	^ aClass class methodDictionary anySatisfy: [ :compiledMethod |
		compiledMethod application = anApp and: [
			self tonelMethods noneSatisfy: [ :anMCMethod |
				anMCMethod isClassSide and: [
					compiledMethod selector = anMCMethod selector ] ] ] ]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> hasInstanceMethodsRemovedFrom: aClass in: emAppOrSubapp [

	^ aClass methodDictionary anySatisfy: [ :compiledMethod |
		compiledMethod application = emAppOrSubapp and: [
			self tonelMethods noneSatisfy: [ :aTonelMethod |
				aTonelMethod isClassSide not and: [
					compiledMethod selector = aTonelMethod selector ] ] ] ]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> hasMethodsRemovedFrom: aClass in: emAppOrSubApp [
	^(self hasInstanceMethodsRemovedFrom: aClass in: emAppOrSubApp)
		or: [self hasClassMethodsRemovedFrom: aClass in: emAppOrSubApp]
]

{ #category : 'testing' }
TonelReaderAbstractClassDefinition >> isArtificiallyCreatedMethod: aCompiledMethod inApp: emApplication [
	"Answer whether aCompiledMethod was artificially created for emApplication.
	 
	 We call artificial to a method that was not in the original source code,
	 but was created to represent some metadata or helper."
	 

	((aCompiledMethod selector beginsWithSubCollection: '_SHAREDPOOL_')
		or: [aCompiledMethod selector beginsWithSubCollection: '_PRAGMA_'])
			ifTrue: [| parts poolName |
				parts := aCompiledMethod selector subStrings: '_'.
				parts size > 1 ifFalse: [^false].
				poolName := (parts at: 2) asSymbol.
				^(Smalltalk at: poolName ifAbsent: [])
					ifNil: [false]
					ifNotNil: [:pool |
						(emApplication sharedPoolNames includes: poolName)
							and: [pool isKindOf: EsPoolDictionary]]].
	(aCompiledMethod selector beginsWithSubCollection: '_TONEL_') ifTrue: [^true].
	^false
]

{ #category : 'loading' }
TonelReaderAbstractClassDefinition >> loadDeclarationMethodsInto: anApp using: aTonelLoader [
	"Load declaration methods (as in pragma declarations) into an App
	 using aTonelLoader."

	| concreteClass |
	concreteClass := self concreteClassIn: anApp.
	(self tonelMethods select: [:method | method isDeclaration]) do: 
			[:aTonelMethod | 
			aTonelMethod 
				loadFor: concreteClass
				into: anApp
				using: aTonelLoader]
]

{ #category : 'loading' }
TonelReaderAbstractClassDefinition >> loadInto: anApp using: appLoader [
	"Loads receiver into anApp using an appLoader <TonelApplicationLoader>."

	appLoader loader
		changeUserTo: anApp manager
		for: [
			self
				loadMethodsInto: anApp using: appLoader;
				deleteRemovedMethodsFrom: anApp using: appLoader;
				updateCommentIn: anApp
				].
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> loadMethodsInto: anApp using: aTonelLoader [

	| concreteClass |

	concreteClass := self concreteClassIn: anApp.
	self tonelMethods do: [:aTonelMethod |
		aTonelMethod loadFor: concreteClass into: anApp using: aTonelLoader.
		aTonelMethod isDeclaration ifTrue: [EmInterface current rebuildNamespaceFor: anApp]
	]
]

{ #category : 'loading-changes',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> makeConsistentIn: anApp [
	"Load the current edition, which is similar to 'ReLoad Current'. This is done to
	  ensure that the loaded edition is consistent in the library (and can be versioned)"
	EmImageBuilder
		loadClasses: (Array with: ((self concreteClassIn: anApp) asEditionIn: anApp))
]

{ #category : 'loading-changes',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> methodChangesIn: aClass [

	^self tonelMethods select: [:aTonelMethod | aTonelMethod hasChangesIn: aClass]
]

{ #category : 'loading-changes',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> removeCompiledMethod: compiledMethod from: emApp [

	TonelLoader
		do: [EmInterface current removeMethods: (Array with: compiledMethod)]
		withSuperUser: emApp manager
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> shouldCreateEditionOf: baseClass in: anApp using: aTonelLoader [

	^(baseClass isEditionIn: anApp) not and: 
			[aTonelLoader alwaysCreateEditions 
				or: [self hasChangesIn: anApp comparedTo: baseClass]]
]

{ #category : 'loading' }
TonelReaderAbstractClassDefinition >> updateCommentIn: anApp [
	"If the receiver represents a class definition, then update the
	 class comment if it has changed."
	 	
	
]

{ #category : 'loading' }
TonelReaderAbstractClassDefinition >> versionClass: emClass in: anApp using: aLoader [
	"Versions the edition of emClass in anApp (or subapp) using aLoader."

	((emClass isEditionIn: anApp) and: [aLoader hasVersionName])
		ifTrue: [
			TonelLoader
				do: [emClass versionNameIn: anApp is: aLoader versionName]
				forApp: anApp
				withSuperUser: (emClass developerIn: anApp).

			TonelLoader
				do: [anApp releaseClass: emClass]
				forApp: anApp
				withSuperUser: (emClass ownerIn: emClass controller)

			]
]

{ #category : 'loading' }
TonelReaderAbstractClassDefinition >> versionIn: anApp using: aTonelLoader [
	"Versions the edition of anApp using aTonelLoader."

	| emClass |

	"self makeConsistentIn: anApp."
	emClass := Smalltalk classAt: self identifier.
	self versionClass: emClass in: anApp using: aTonelLoader
	
]
