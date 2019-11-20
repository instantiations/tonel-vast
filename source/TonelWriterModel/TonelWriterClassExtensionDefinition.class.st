Class {
	#name : 'TonelWriterClassExtensionDefinition',
	#superclass : 'TonelWriterAbstractClassDefinition',
	#category : 'TonelWriterModel'
}

{ #category : 'Instance Creation' }
TonelWriterClassExtensionDefinition class >> of: aClass extendedIn: anApplication [

	^self new initializeOf: aClass extendedIn: anApplication
]

{ #category : 'Accessing' }
TonelWriterClassExtensionDefinition >> categoryFormattedAsExtensionOf: anApp [

	^'*' , (anApp tonelPackageName)
]

{ #category : 'Accessing' }
TonelWriterClassExtensionDefinition >> extendedClassName [

	^class name
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelWriterClassExtensionDefinition >> extensionMethodDefinitionsOf: aClassOrMetaclass [

	^((aClassOrMetaclass allSelectorsFor: application)
		reject: [:selector | self isTonelSpecialSelector: selector])
			collect: [:selector |
				TonelWriterMethodDefinition
					uniquelyKnownAs: selector
					in: aClassOrMetaclass
					categorizedAs: (self categoryFormattedAsExtensionOf: application)]
]

{ #category : 'Accessing' }
TonelWriterClassExtensionDefinition >> fileName [

	^'<1s>.extension.st' expandMacrosWith: class asString
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelWriterClassExtensionDefinition >> initializeOf: aClass extendedIn: anApplication [

	class := aClass.
	application := anApplication
]

{ #category : 'Printing' }
TonelWriterClassExtensionDefinition >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $<;
		print: class;
		nextPut: $>;
		nextPut: $[;
		print: application;
		nextPut: $]
]

{ #category : 'Accessing' }
TonelWriterClassExtensionDefinition >> withClassMethodDefinitionsDo: aBlock [

	self
		withExtensionMethodDefinitionsOf: class class
		do: [:methodDefinition | aBlock value: methodDefinition]
]

{ #category : 'Accessing' }
TonelWriterClassExtensionDefinition >> withExtensionMethodDefinitionsOf: aClassOrMetaclass do: aBlock [

	(self extensionMethodDefinitionsOf: aClassOrMetaclass)
		do: [:methodDefinition | aBlock value: methodDefinition]
]

{ #category : 'Accessing' }
TonelWriterClassExtensionDefinition >> withInstanceMethodDefinitionsDo: aBlock [

	self
		withExtensionMethodDefinitionsOf: class
		do: [:methodDefinition | aBlock value: methodDefinition]
]
