Class {
	#name : 'TonelClassWriter',
	#superclass : 'TonelArtifactWriter',
	#instVars : [
		'packageDirectory',
		'methodWriter'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelClassWriter >> format: aVariablesCollection [

	^(',' , lineDelimiter , Character tab asString , Character tab asString)
		join: (aVariablesCollection collect: [:variable | self wrapBetweenSingleQuotes: variable])
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelClassWriter >> methodWriter [

	^methodWriter ifNil: [methodWriter := (TonelMethodWriter with: lineDelimiter)]
]

{ #category : 'Writing' }
TonelClassWriter >> tonelTypeName [
	^'Class'
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

	self ensureDirectory.
	self withStreamOn: (self filePathFor: aClassDefinition)
		do: [:writeStream | self write: aClassDefinition on: writeStream]
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
			ifFalse: [self methodWriter write: methodDefinition on: aWriteStream]]
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
		self methodWriter write: methodDefition on: aWriteStream]
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
