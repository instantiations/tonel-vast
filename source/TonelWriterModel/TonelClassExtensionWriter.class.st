Class {
	#name : 'TonelClassExtensionWriter',
	#superclass : 'TonelClassWriter',
	#category : 'TonelWriterModel'
}

{ #category : 'Writing' }
TonelClassExtensionWriter >> write: aClassExtensionDefinition [

	self directory exists ifFalse: [self directory realize].
	self
		withStreamOn: (self filePathFor: aClassExtensionDefinition)
		do: [:writeStream | self write: aClassExtensionDefinition on: writeStream]
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassExtensionWriter >> write: aClassExtensionDefinition on: aWriteStream [

	^self
		writeDefinitionOf: aClassExtensionDefinition on: aWriteStream;
		writeClassMethodsOf: aClassExtensionDefinition on: aWriteStream;
		writeInstanceMethodsOf: aClassExtensionDefinition on: aWriteStream
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassExtensionWriter >> writeClassMethodsOf: aClassExtensionDefinition on: aWriteStream [

	aClassExtensionDefinition withClassMethodDefinitionsDo: [:methodDefition |
		self methodWriter write: methodDefition on: aWriteStream]
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassExtensionWriter >> writeDefinitionOf: aClassExtensionDefinition on: aWriteStream [

	aWriteStream << 'Extension {' << lineDelimiter << Character tab << '#name : ' <<
		aClassExtensionDefinition extendedClassName asString printString << lineDelimiter << '}' <<
		lineDelimiter
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassExtensionWriter >> writeInstanceMethodsOf: aClassExtensionDefinition on: aWriteStream [

	aClassExtensionDefinition withInstanceMethodDefinitionsDo: [:methodDefition |
		self methodWriter write: methodDefition on: aWriteStream]
]
