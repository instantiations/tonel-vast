Class {
	#name : 'TonelClassWriter',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'packageDirectory',
		'lineDelimiter',
		'methodWriter'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Instance Creation' }
TonelClassWriter class >> writingOn: aFileSystem into: aPackageDirectory lineDelimiter: aLineDelimiter [

	^self new initializeWritingOn: aFileSystem into: aPackageDirectory lineDelimiter: aLineDelimiter
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelClassWriter >> filePathFor: aClassDefinition [

	^packageDirectory append: aClassDefinition fileName
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelClassWriter >> format: aVariablesCollection [

	^(',' , lineDelimiter , Character tab asString , Character tab asString)
		join: (aVariablesCollection collect: [:variable | self wrapBetweenSingleQuotes: variable])
]

{ #category : 'Initialization' }
TonelClassWriter >> initializeWritingOn: aFileSystem into: aPackageDirectory lineDelimiter: aLineDelimiter [

	fileSystem := aFileSystem.
	packageDirectory := aPackageDirectory.
	lineDelimiter := aLineDelimiter.
	methodWriter := TonelMethodWriter with: lineDelimiter
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelClassWriter >> withStreamOn: aFilePath do: aBlock [

	fileSystem
		createWriteStreamOn: aFilePath
		during: [:writeStream | aBlock value: (TonelUTF8StreamWriterWrapper wrapping: writeStream)]
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelClassWriter >> wrapBetweenSingleQuotes: aVariable [

	^String streamContents: [:stream |
		stream
			nextPut: $';
			nextPutAll: aVariable;
			nextPut: $']
]

{ #category : 'Writing' }
TonelClassWriter >> write: aClassDefinition [

	packageDirectory exists ifFalse: [packageDirectory realize].
	self
		withStreamOn: (self filePathFor: aClassDefinition)
		do: [:writeStream | self write: aClassDefinition on: writeStream]
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> write: aBlock betweenCurlyBracesOn: aWriteStream [

	aWriteStream << 'Class {' << lineDelimiter.
	aBlock value: aWriteStream.
	aWriteStream << lineDelimiter << '}' << lineDelimiter
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> write: aClassDefinition on: aWriteStream [

	^self
		writeDefinitionOf: aClassDefinition on: aWriteStream;
		writeClassMethodsOf: aClassDefinition on: aWriteStream;
		writeInstanceMethodsOf: aClassDefinition on: aWriteStream
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> write: aVariablesCollection on: aWriteStream under: aKey [

	| formattedVariables |

	formattedVariables := self format: aVariablesCollection.

	aVariablesCollection isEmpty
		ifFalse: [
			aWriteStream
				nextPutAll: lineDelimiter;
				tab;
				nextPutAll: ('#<1s> : [' expandMacrosWith: aKey);
				nextPutAll: lineDelimiter;
				tab;
				tab;
				nextPutAll: formattedVariables;
				nextPutAll: lineDelimiter;
				tab;
				nextPutAll: '],']
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeCategoryOf: aClassDefinition on: aWriteStream [

	aWriteStream
		nextPutAll: lineDelimiter;
		tab;
		nextPutAll: ('#category : <1p>' expandMacrosWith: aClassDefinition tonelPackageName)
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeClassMethodsOf: aClassDefinition on: aWriteStream [

	aClassDefinition withClassMethodDefinitionsDo: [:methodDefinition |
		methodDefinition isRealPragma
			ifFalse: [methodWriter write: methodDefinition on: aWriteStream]]
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeCommentOf: aClassDefinition on: aWriteStream [

	aClassDefinition withFormattedCommentDo: [:comment |
		aWriteStream << '"' << lineDelimiter << comment << lineDelimiter << '"' << lineDelimiter]
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeDefinitionOf: aClassDefinition on: aWriteStream [

	self writeCommentOf: aClassDefinition on: aWriteStream.
	self
		write: [:stream |
			self
				writeNameAndSuperclassOf: aClassDefinition on: stream;
				writeVariablesOf: aClassDefinition on: stream;
				writeSubclassTypeOf: aClassDefinition on: stream;
				writeCategoryOf: aClassDefinition on: stream]
		betweenCurlyBracesOn: aWriteStream
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeInstanceMethodsOf: aClassDefinition on: aWriteStream [

	aClassDefinition withInstanceMethodDefinitionsDo: [:methodDefition |
		methodWriter write: methodDefition on: aWriteStream]
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeNameAndSuperclassOf: aClassDefinition on: aWriteStream [

	aWriteStream
		tab;
		nextPutAll: ('#name : <1p>,' expandMacrosWith: aClassDefinition definedClassName asString);
		nextPutAll: lineDelimiter;
		tab;
		nextPutAll: (
			'#superclass : <1p>,'
				expandMacrosWith: aClassDefinition definedClassSuperclassName asString)
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeSubclassTypeOf: aClassDefinition on: aWriteStream [

	aClassDefinition hasDefaultSubclassType
		ifFalse: [
			aWriteStream
				nextPutAll: lineDelimiter;
				tab;
				nextPutAll:
					('#type : <1p>,' expandMacrosWith: aClassDefinition subclassType asString)]
]

{ #category : 'Writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeVariablesOf: aClassDefinition on: aWriteStream [

	self
		write: aClassDefinition instanceVariableNames on: aWriteStream under: 'instVars';
		write: aClassDefinition classVariableNames on: aWriteStream under: 'classVars';
		write: aClassDefinition poolNames on: aWriteStream under: 'pools';
		write: aClassDefinition classInstanceVariableNames on: aWriteStream under: 'classInstVars'
]
