Class {
	#name : 'TonelReaderDefinition',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'TonelReaderModel'
}

{
	#category : 'constants'
}
TonelReaderDefinition class >> definitionType [

	self subclassResponsibility
]

{
	#category : 'Instance Creation'
}
TonelReaderDefinition class >> fromMetadata: aDictionary [

	^self new
		initializeFromMetadata: aDictionary;
		yourself
]

{
	#category : 'Instance Creation'
}
TonelReaderDefinition class >> name: aString [

	^self new
		initializeWith: aString;
		yourself
]

{
	#category : 'Initialization',
	#vaVisibility : 'private'
}
TonelReaderDefinition >> initializeFromMetadata: aDictionary [

	name := aDictionary at: #name

]

{
	#category : 'Initialization',
	#vaVisibility : 'private'
}
TonelReaderDefinition >> initializeWith: aString [

	name := aString.

]

{
	#category : 'accessing'
}
TonelReaderDefinition >> name [
	^name
]

{
	#category : 'accessing'
}
TonelReaderDefinition >> name: anObject [
	name := anObject
]

{
	#category : 'printing'
}
TonelReaderDefinition >> printIdentifierOn: aStream [

		aStream 
			nextPut: $[;
			nextPutAll: (self name ifNil: [#unnamed] ifNotNil: [:v | v]) printString;
			nextPut: $]
			
]

{
	#category : 'printing'
}
TonelReaderDefinition >> printOn: aStream [

	self printTonelTypeOn: aStream.
	self printIdentifierOn: aStream
]

{
	#category : 'printing'
}
TonelReaderDefinition >> printTonelTypeOn: aStream [

	super printOn: aStream
]
