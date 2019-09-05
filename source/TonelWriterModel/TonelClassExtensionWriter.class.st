Class {
	#name : 'TonelClassExtensionWriter',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'filePath',
		'lineDelimiter',
		'methodWriter'
	],
	#category : 'TonelWriterModel'
}

{
	#category : 'Instance Creation'
}
TonelClassExtensionWriter class >> writingOn: aFileSystem into: aPackageDirectory lineDelimiter: aLineDelimiter [

	^self new initializeWritingOn: aFileSystem into: aPackageDirectory lineDelimiter: aLineDelimiter
]

{
	#category : 'Utility',
	#vaVisibility : 'private'
}
TonelClassExtensionWriter >> filePathFor: aClassExtensionDefinition [

	^filePath append: aClassExtensionDefinition fileName
]

{
	#category : 'Initialization'
}
TonelClassExtensionWriter >> initializeWritingOn: aFileSystem into: aPackageDirectory lineDelimiter: aLineDelimiter [

	fileSystem := aFileSystem.
	filePath := aPackageDirectory.
	lineDelimiter := aLineDelimiter.
	methodWriter := TonelMethodWriter with: lineDelimiter
]

{
	#category : 'Utility',
	#vaVisibility : 'private'
}
TonelClassExtensionWriter >> withStreamOn: aFilePath do: aBlock [

	fileSystem
		createWriteStreamOn: aFilePath asString
		during: [:writeStream | aBlock value: (TonelUTF8StreamWriterWrapper wrapping: writeStream)]
]

{
	#category : 'Writing'
}
TonelClassExtensionWriter >> write: aClassExtensionDefinition [

	filePath exists ifFalse: [filePath realize].
	self
		withStreamOn: (self filePathFor: aClassExtensionDefinition)
		do: [:writeStream | self write: aClassExtensionDefinition on: writeStream]
]

{
	#category : 'Writing',
	#vaVisibility : 'private'
}
TonelClassExtensionWriter >> write: aClassExtensionDefinition on: aWriteStream [

	^self
		writeDefinitionOf: aClassExtensionDefinition on: aWriteStream;
		writeClassMethodsOf: aClassExtensionDefinition on: aWriteStream;
		writeInstanceMethodsOf: aClassExtensionDefinition on: aWriteStream
]

{
	#category : 'Writing',
	#vaVisibility : 'private'
}
TonelClassExtensionWriter >> writeClassMethodsOf: aClassExtensionDefinition on: aWriteStream [

	aClassExtensionDefinition withClassMethodDefinitionsDo: [:methodDefition |
		methodWriter write: methodDefition on: aWriteStream]
]

{
	#category : 'Writing',
	#vaVisibility : 'private'
}
TonelClassExtensionWriter >> writeDefinitionOf: aClassExtensionDefinition on: aWriteStream [

	aWriteStream << 'Extension {' << lineDelimiter << Character tab << '#name : ' <<
		aClassExtensionDefinition extendedClassName asString printString << lineDelimiter << '}' <<
		lineDelimiter
]

{
	#category : 'Writing',
	#vaVisibility : 'private'
}
TonelClassExtensionWriter >> writeInstanceMethodsOf: aClassExtensionDefinition on: aWriteStream [

	aClassExtensionDefinition withInstanceMethodDefinitionsDo: [:methodDefition |
		methodWriter write: methodDefition on: aWriteStream]
]
