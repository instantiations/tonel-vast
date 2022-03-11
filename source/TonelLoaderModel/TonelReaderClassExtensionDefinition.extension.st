Extension {
	#name : 'TonelReaderClassExtensionDefinition'
}

{ #category : '*TonelLoaderModel',
 #vaCategories : ['accessing'] }
TonelReaderClassExtensionDefinition >> concreteClassIn: anApp [
	"Answer the concrete class (it is, the actual Smalltalk class) defined by receiver."
	
	^(anApp extended) detect: [:ea | ea name = self identifier] ifNone: []
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderClassExtensionDefinition >> createEditionIn: anApp using: aTonelLoader [
	"Creates an edition for receiver in anApp (or Subapp) using aTonelLoader."


	| baseClass |

	(baseClass := self concreteClassIn: anApp) isNil
		ifTrue: [self createIn: anApp using: aTonelLoader]
		ifFalse: [
			(self shouldCreateEditionOf: baseClass in: anApp using: aTonelLoader)
				ifTrue: [anApp newClassEditionFor: baseClass ifUnable: []]]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderClassExtensionDefinition >> createExtendedIn: anApp using: aTonelLoader [
	"Creates an extension for receiver class in anApp using aTonelLoader."

	anApp createEditionOf: (Smalltalk classAt: self identifier) type: #Extended ifUnable: [^nil]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderClassExtensionDefinition >> createIn: anApp using: aTonelLoader [
	"Creates receiver in anApp using aTonelLoader."

	self createExtendedIn: anApp using: aTonelLoader
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'] }
TonelReaderClassExtensionDefinition >> hasChangesIn: anApp comparedTo: aClass [
	"Answer whether receiver has changes inApp comparing it
	 to the concrete class defined in such app."

	^(self methodChangesIn: aClass) notEmpty
			or: [ self hasMethodsRemovedFrom: aClass in: anApp ]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['comparing'] }
TonelReaderClassExtensionDefinition >> tonelTopologicalSubordinateOf: aTonelLoaderClass [
	"This method will return true if the receiver is a extension of aTonelLoaderClass."

	^aTonelLoaderClass extension not and: [self name = aTonelLoaderClass name]
]
