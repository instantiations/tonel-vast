Class {
	#name : 'TonelClassWriter',
	#superclass : 'TonelArtifactWriter',
	#instVars : [
		'packageDirectory',
		'methodWriter'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'utility',
  #vaVisibility : 'private' }
TonelClassWriter >> format: aVariablesCollection [

	^(',' , lineDelimiter , Character tab asString , Character tab asString)
		join: (aVariablesCollection collect: [:variable | self wrapBetweenSingleQuotes: variable])
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelClassWriter >> methodWriter [

	^methodWriter ifNil: [methodWriter := (TonelMethodWriter in: self parent)]
]

{ #category : 'writing' }
TonelClassWriter >> tonelTypeName [
	^'Class'
]

{ #category : 'utility',
  #vaVisibility : 'private' }
TonelClassWriter >> wrapBetweenSingleQuotes: aVariable [

	^String streamContents: [:stream |
		stream
			nextPut: $';
			nextPutAll: aVariable;
			nextPut: $']
]

{ #category : 'writing' }
TonelClassWriter >> write: aClassDefinition [

	self ensureDirectory.
	self withStreamOn: (self filePathFor: aClassDefinition)
		do: [:writeStream | self write: aClassDefinition on: writeStream]
]

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelClassWriter >> write: aClassDefinition on: aWriteStream [

	^self
		writeDefinitionOf: aClassDefinition on: aWriteStream;
		writeClassMethodsOf: aClassDefinition on: aWriteStream;
		writeInstanceMethodsOf: aClassDefinition on: aWriteStream
]

{ #category : 'writing',
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

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeCategoryOf: aClassDefinition on: aWriteStream [

	aWriteStream
		nextPutAll: lineDelimiter;
		tab;
		nextPutAll: ('#category : <1p>' expandMacrosWith: aClassDefinition category)
]

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeClassMethodsOf: aClassDefinition on: aWriteStream [

	aClassDefinition withClassMethodDefinitionsDo: [:methodDefinition |
		methodDefinition writeUsing: self methodWriter on: aWriteStream]
]

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeCommentOf: aClassDefinition on: aWriteStream [

	aClassDefinition withFormattedCommentDo: [:comment |
		aWriteStream << '"' << lineDelimiter << comment << lineDelimiter << '"' << lineDelimiter]
]

{ #category : 'writing',
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

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeInstanceMethodsOf: aClassDefinition on: aWriteStream [

	aClassDefinition withInstanceMethodDefinitionsDo: [:methodDefition |
		self methodWriter write: methodDefition on: aWriteStream]
]

{ #category : 'writing',
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

{ #category : 'writing',
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

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelClassWriter >> writeVariablesOf: aClassDefinition on: aWriteStream [

	self
		write: aClassDefinition instanceVariableNames on: aWriteStream under: 'instVars';
		write: aClassDefinition classVariableNames on: aWriteStream under: 'classVars';
		write: aClassDefinition poolNames on: aWriteStream under: 'pools';
		write: aClassDefinition classInstanceVariableNames on: aWriteStream under: 'classInstVars'
]
