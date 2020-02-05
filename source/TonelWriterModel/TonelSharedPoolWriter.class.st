Class {
	#name : 'TonelSharedPoolWriter',
	#superclass : 'TonelClassWriter',
	#category : 'TonelWriterModel'
}

{ #category : 'writing' }
TonelSharedPoolWriter >> writeClassMethodsOf: aClassDefinition on: aWriteStream [

	aClassDefinition poolInitializationMethods do: [:method |
		self methodWriter write: method on: aWriteStream.
	]
]

{ #category : 'writing' }
TonelSharedPoolWriter >> writeInstanceMethodsOf: aClassDefinition on: aWriteStream [

]
