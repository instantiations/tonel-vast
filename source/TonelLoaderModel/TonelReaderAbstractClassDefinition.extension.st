Extension {
	#name : 'TonelReaderAbstractClassDefinition'
}

{ #category : '*TonelLoaderModel',
 #vaCategories : ['accessing'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> concreteClassIn: anApp [

	self subclassResponsibility 
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-changes'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> deleteRemovedClassMethodsFrom: aClass in: anApp [

	aClass class methodDictionary do: 
			[:compiledMethod | 
			(compiledMethod application = anApp and: 
					[self tonelMethods noneSatisfy: 
							[:anMCMethod | 
							anMCMethod isClassSide 
								and: [compiledMethod selector = anMCMethod selector]]]) 
				ifTrue: [self removeCompiledMethod: compiledMethod from: anApp]]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-changes'],
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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-changes'],
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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'] }
TonelReaderAbstractClassDefinition >> hasChangesIn: emAppOrSubApp [

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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> hasChangesIn: anApp comparedTo: aClass [

	self subclassResponsibility
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> hasClassMethodsRemovedFrom: aClass in: anApp [

	^ aClass class methodDictionary anySatisfy: [ :compiledMethod |
		compiledMethod application = anApp and: [
			self tonelMethods noneSatisfy: [ :anMCMethod |
				anMCMethod isClassSide and: [
					compiledMethod selector = anMCMethod selector ] ] ] ]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> hasInstanceMethodsRemovedFrom: aClass in: emAppOrSubapp [

	^ aClass methodDictionary anySatisfy: [ :compiledMethod |
		compiledMethod application = emAppOrSubapp and: [
			self tonelMethods noneSatisfy: [ :aTonelMethod |
				aTonelMethod isClassSide not and: [
					compiledMethod selector = aTonelMethod selector ] ] ] ]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> hasMethodsRemovedFrom: aClass in: emAppOrSubApp [
	^(self hasInstanceMethodsRemovedFrom: aClass in: emAppOrSubApp)
		or: [self hasClassMethodsRemovedFrom: aClass in: emAppOrSubApp]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderAbstractClassDefinition >> loadDeclarationMethodsInto: anApp using: aTonelLoader [

	| concreteClass |
	concreteClass := self concreteClassIn: anApp.
	(self tonelMethods select: [:method | method isDeclaration]) do: 
			[:aTonelMethod | 
			aTonelMethod 
				loadFor: concreteClass
				into: anApp
				using: aTonelLoader]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderAbstractClassDefinition >> loadInto: anApp using: aLoader [

	aLoader
		changeUserTo: anApp manager
		for: [
			self
				loadMethodsInto: anApp using: aLoader;
				deleteRemovedMethodsFrom: anApp using: aLoader;
				updateCommentIn: anApp
				].
	"self makeConsistentIn: anApp"
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> loadMethodsInto: anApp using: aTonelLoader [

	| concreteClass |
	concreteClass := self concreteClassIn: anApp.
	self tonelMethods do: 
			[:aTonelMethod | 
			aTonelMethod 
				loadFor: concreteClass
				into: anApp
				using: aTonelLoader]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-changes'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> makeConsistentIn: anApp [
	"Load the current edition, which is similar to 'ReLoad Current'. This is done to
	  ensure that the loaded edition is consistent in the library (and can be versioned)"
	EmImageBuilder
		loadClasses: (Array with: ((self concreteClassIn: anApp) asEditionIn: anApp))
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-changes'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> methodChangesIn: aClass [

	^self tonelMethods select: [:aTonelMethod | aTonelMethod hasChangesIn: aClass]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-changes'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> removeCompiledMethod: compiledMethod from: emApp [

	self
		do: [EmInterface current removeMethods: (Array with: compiledMethod)]
		withSuperUser: emApp manager
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'],
  #vaVisibility : 'private' }
TonelReaderAbstractClassDefinition >> shouldCreateEditionOf: baseClass in: anApp using: aTonelLoader [

	^(baseClass isEditionIn: anApp) not and: 
			[aTonelLoader alwaysCreateEditions 
				or: [self hasChangesIn: anApp comparedTo: baseClass]]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderAbstractClassDefinition >> updateCommentIn: anApp [
	"If the receiver represents a class definition, then update the
	 class comment if it has changed."
	 	
	
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderAbstractClassDefinition >> versionClass: emClass in: anApp using: aLoader [

	((emClass isEditionIn: anApp) and: [aLoader hasVersionName])
		ifTrue: [
			self
				do: [emClass versionNameIn: anApp is: aLoader versionName]
				forApp: anApp
				withSuperUser: (emClass developerIn: anApp).

			self
				do: [anApp releaseClass: emClass]
				forApp: anApp
				withSuperUser: (emClass ownerIn: emClass controller)

			]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderAbstractClassDefinition >> versionIn: anApp using: aTonelLoader [

	| emClass |

	"self makeConsistentIn: anApp."
	emClass := Smalltalk classAt: self identifier.
	self versionClass: emClass in: anApp using: aTonelLoader
	
]
