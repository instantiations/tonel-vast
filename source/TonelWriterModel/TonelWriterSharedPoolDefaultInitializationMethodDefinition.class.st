Class {
	#name : 'TonelWriterSharedPoolDefaultInitializationMethodDefinition',
	#superclass : 'TonelWriterSharedPoolInitializationMethodDefinition',
	#category : 'TonelWriterModel'
}

{
	#category : 'accessing'
}
TonelWriterSharedPoolDefaultInitializationMethodDefinition >> methodBody [

	| stream |

	stream := WriteStream on: String new.
	self pool pool associations do: [:assoc |
		assoc key first = $!
			ifFalse: [
				stream
					tab;
					nextPutAll: assoc key;
					nextPutAll: ' := ';
					nextPutAll: assoc value printString;
					nextPut: $.;
					cr]].
	^stream contents
]

{
	#category : 'accessing'
}
TonelWriterSharedPoolDefaultInitializationMethodDefinition >> methodDeclaration [

	^'initialize'
]
