Class {
	#name : 'TonelWriterClassExtensionDefinition',
	#superclass : 'TonelWriterAbstractClassDefinition',
	#category : 'TonelWriterModel'
}

{ #category : 'Instance Creation' }
TonelWriterClassExtensionDefinition class >> of: aClass extendedIn: anApplication [

	^self new initializeOf: aClass extendedIn: anApplication
]

{ #category : 'accessing' }
TonelWriterClassExtensionDefinition >> categoryFormattedAsExtensionOf: anApplication [

	^'*' , anApplication tonelPackageName
]

{ #category : 'accessing' }
TonelWriterClassExtensionDefinition >> extendedClassName [

	^class name
]

{ #category : 'accessing',
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

{ #category : 'accessing' }
TonelWriterClassExtensionDefinition >> fileName [

	^'<1s>.extension.st' expandMacrosWith: class asString
]

{ #category : 'initializing',
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

{ #category : 'accessing' }
TonelWriterClassExtensionDefinition >> withClassMethodDefinitionsDo: aBlock [

	self
		withExtensionMethodDefinitionsOf: class class
		do: [:methodDefinition | aBlock value: methodDefinition]
]

{ #category : 'accessing' }
TonelWriterClassExtensionDefinition >> withExtensionMethodDefinitionsOf: aClassOrMetaclass do: aBlock [

	(self extensionMethodDefinitionsOf: aClassOrMetaclass)
		do: [:methodDefinition | aBlock value: methodDefinition]
]

{ #category : 'accessing' }
TonelWriterClassExtensionDefinition >> withInstanceMethodDefinitionsDo: aBlock [

	self
		withExtensionMethodDefinitionsOf: class
		do: [:methodDefinition | aBlock value: methodDefinition]
]
