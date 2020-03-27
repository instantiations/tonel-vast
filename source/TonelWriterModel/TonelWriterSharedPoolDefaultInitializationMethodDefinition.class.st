Class {
	#name : 'TonelWriterSharedPoolDefaultInitializationMethodDefinition',
	#superclass : 'TonelWriterSharedPoolInitializationMethodDefinition',
	#category : 'TonelWriterModel'
}

{ #category : 'accessing' }
TonelWriterSharedPoolDefaultInitializationMethodDefinition >> methodBody [
	| stream |
	stream := WriteStream on: String new.
	self poolDeclarations do: 
			[:declaration | 
			declaration name first = $! 
				ifFalse: [self writeDeclaration: declaration on: stream]].
	^stream contents
]

{ #category : 'accessing' }
TonelWriterSharedPoolDefaultInitializationMethodDefinition >> methodDeclaration [

	^'initialize'
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterSharedPoolDefaultInitializationMethodDefinition >> poolDeclarations [

	^self definitionClass poolDeclarations


]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterSharedPoolDefaultInitializationMethodDefinition >> writeDeclaration: declaration on: stream [

	| value |
	value := declaration valueExpression.
	^stream
		tab;
		nextPutAll: declaration name;
		nextPutAll: ' := ';
		nextPutAll: (value isEmptyOrNil ifTrue: ['nil'] ifFalse: [value]);
		nextPut: $.;
		cr
]
