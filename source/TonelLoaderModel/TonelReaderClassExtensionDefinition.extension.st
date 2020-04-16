Extension {
	#name : 'TonelReaderClassExtensionDefinition'
}

{ #category : '*TonelLoaderModel',
 #vaCategories : ['accessing'] }
TonelReaderClassExtensionDefinition >> concreteClassIn: anApp [

	^(anApp extended) detect: [:ea | ea name = self identifier] ifNone: []
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderClassExtensionDefinition >> createEditionIn: anApp using: aTonelLoader [

	| baseClass |
	(baseClass := self concreteClassIn: anApp) isNil 
		ifTrue: [self createIn: anApp]
		ifFalse: 
			[(self 
				shouldCreateEditionOf: baseClass
				in: anApp
				using: aTonelLoader) 
					ifTrue: [anApp newClassEditionFor: baseClass ifUnable: []]]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderClassExtensionDefinition >> createExtendedIn: anApp [

	EmInterface current extend: (Smalltalk classAt: self identifier) in: anApp
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderClassExtensionDefinition >> createIn: anApp [

	self createExtendedIn: anApp
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'] }
TonelReaderClassExtensionDefinition >> hasChangesIn: anApp comparedTo: aClass [
	^(self methodChangesIn: aClass) notEmpty
			or: [ self hasMethodsRemovedFrom: aClass in: anApp ]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderClassExtensionDefinition >> loadMethodsInto: anApp using: aTonelLoader [

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
 #vaCategories : ['accessing'] }
TonelReaderClassExtensionDefinition >> rootTonelApplicationIn: aTonelLoader [


	^aTonelLoader rootApplicationOfClassExtension: self
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['comparing'] }
TonelReaderClassExtensionDefinition >> tonelTopologicalSubordinateOf: aTonelLoaderClass [
	"This method will return true if the receiver is a extension of aTonelLoaderClass."

	^aTonelLoaderClass extension not and: [self name = aTonelLoaderClass name]
]
