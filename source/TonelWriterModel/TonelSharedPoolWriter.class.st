Class {
	#name : 'TonelSharedPoolWriter',
	#superclass : 'TonelClassWriter',
	#category : 'TonelWriterModel'
}

{
	#category : 'Not categorized'
}
TonelSharedPoolWriter >> writeClassMethodsOf: aClassDefinition on: aWriteStream [

	aClassDefinition poolInitializationMethods do: [:method |
		methodWriter write: method on: aWriteStream.
	]
]

{
	#category : 'Not categorized'
}
TonelSharedPoolWriter >> writeInstanceMethodsOf: aClassDefinition on: aWriteStream [

]
