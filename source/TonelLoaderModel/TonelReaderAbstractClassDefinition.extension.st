Extension {
	#name : 'TonelReaderAbstractClassDefinition'
}

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['accessing'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> concreteClassIn: anApp [

	self subclassResponsibility 
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading-changes'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> deleteRemovedClassMethodsFrom: aClass in: anApp [

	aClass class methodDictionary do: [ :compiledMethod |
		(compiledMethod application = anApp and: [
			self tonelMethods noneSatisfy: [ :anMCMethod |
				anMCMethod isClassSide and: [
					compiledMethod selector = anMCMethod selector ] ] ])
						ifTrue: [ EmInterface current removeMethods: (Array with: compiledMethod) ] ]
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading-changes'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> deleteRemovedInstanceMethodsFrom: aClass in: anApp [

	aClass methodDictionary do: [ :compiledMethod |
		(compiledMethod application = anApp and: [
			self tonelMethods noneSatisfy: [ :anMCMethod |
				anMCMethod isClassSide not and: [
					compiledMethod selector = anMCMethod selector ] ] ])
						ifTrue: [ EmInterface current removeMethods: (Array with: compiledMethod) ] ]
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading-changes'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> deleteRemovedMethodsFrom: anApp [
	| concreteClass |
	concreteClass := self concreteClassIn: anApp.
	self
		deleteRemovedInstanceMethodsFrom: concreteClass in: anApp;
		deleteRemovedClassMethodsFrom: concreteClass in: anApp
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['testing'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> hasClassMethodsRemovedFrom: aClass in: anApp [

	^ aClass class methodDictionary anySatisfy: [ :compiledMethod |
		compiledMethod application = anApp and: [
			self tonelMethods noneSatisfy: [ :anMCMethod |
				anMCMethod isClassSide and: [
					compiledMethod selector = anMCMethod selector ] ] ] ]
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['testing'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> hasInstanceMethodsRemovedFrom: aClass in: anApp [

	^ aClass methodDictionary anySatisfy: [ :compiledMethod |
		compiledMethod application = anApp and: [
			self tonelMethods noneSatisfy: [ :anMCMethod |
				anMCMethod isClassSide not and: [
					compiledMethod selector = anMCMethod selector ] ] ] ]
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['testing'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> hasMethodsRemovedFrom: aClass in: anApp [
	^(self hasInstanceMethodsRemovedFrom: aClass in: anApp)
		or: [self hasClassMethodsRemovedFrom: aClass in: anApp]
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading']
}
TonelReaderAbstractClassDefinition >> loadInto: anApp [
	self 
		loadMethodsInto: anApp;
		deleteRemovedMethodsFrom: anApp;
		updateCommentIn: anApp;
		makeConsistentIn: anApp
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> loadMethodsInto: anApp [

	| concreteClass |

	concreteClass := self concreteClassIn: anApp.
	self tonelMethods do: [:aTonelMethod | aTonelMethod loadFor: concreteClass into: anApp]
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading-changes'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> makeConsistentIn: anApp [
	"Load the current edition, which is similar to 'ReLoad Current'. This is done to
	  ensure that the loaded edition is consistent in the library (and can be versioned)"
	EmImageBuilder
		loadClasses: (Array with: ((self concreteClassIn: anApp) asEditionIn: anApp))
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading-changes'],
	#vaVisibility : 'private'
}
TonelReaderAbstractClassDefinition >> methodChangesIn: aClass [

	^self tonelMethods select: [:aTonelMethod | aTonelMethod hasChangesIn: aClass]
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading']
}
TonelReaderAbstractClassDefinition >> updateCommentIn: anApp [
	"If the receiver represents a class definition, then update the
	 class comment if it has changed."
	 	
	
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading']
}
TonelReaderAbstractClassDefinition >> versionIn: anApp as: versionName [
	"If @versionName has not been provided, leave the open edition
	 of the class represented by the receiver as-is and answer self.

	 If the receiver represents a class or class extension in @anApp,
	 version the open edition of the class represented by the receiver
	 and release it into @anApp."

	versionName isEmpty ifFalse: [ | theClass |
		self makeConsistentIn: anApp.
		theClass := Smalltalk classAt: self identifier.
		(theClass isEditionIn: anApp) ifTrue: [
			theClass versionNameIn: anApp is: versionName.
			anApp releaseClass: theClass ] ]
]

{
	#category : '*TonelLoaderModel',
	#vaCategories : ['loading']
}
TonelReaderAbstractClassDefinition >> versionIn: anApp for: aLoader [
	"If @versionName has not been provided, leave the open edition
	 of the class represented by the receiver as-is and answer self.

	 If the receiver represents a class or class extension in @anApp,
	 version the open edition of the class represented by the receiver
	 and release it into @anApp."

	aLoader versionName isEmpty ifFalse: [ | theClass |
		self makeConsistentIn: anApp.
		theClass := Smalltalk classAt: self identifier.
		(theClass isEditionIn: anApp) ifTrue: [
			theClass versionNameIn: anApp is: aLoader versionName.
			anApp releaseClass: theClass ] ]
]
