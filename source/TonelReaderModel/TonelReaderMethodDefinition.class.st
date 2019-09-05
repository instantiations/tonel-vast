Class {
	#name : 'TonelReaderMethodDefinition',
	#superclass : 'TonelReaderDefinition',
	#instVars : [
		'className',
		'source',
		'public',
		'classSide',
		'categories',
		'stamp',
		'selector'
	],
	#pools : [
		'CldtConstants',
		'TonelTextConstants'
	],
	#category : 'TonelReaderModel'
}

{
	#category : 'Initialize-Release'
}
TonelReaderMethodDefinition class >> className: nameString classSide: aBoolean categories: aCollection stamp: stampString [

	^self new
		initializeClassName: nameString
		classSide: aBoolean
		categories: aCollection
		stamp: stampString;
		yourself
		
]

{
	#category : 'constants'
}
TonelReaderMethodDefinition class >> definitionType [

	^'Method'
]

{
	#category : 'Comparing'
}
TonelReaderMethodDefinition >> = aReaderMethodDefinition [

	^((((aReaderMethodDefinition isKindOf: TonelReaderMethodDefinition)
		and: [className = aReaderMethodDefinition className])
			and: [selector = aReaderMethodDefinition selector])
				and: [classSide = aReaderMethodDefinition isClassSide])
					and: [public = aReaderMethodDefinition visibility]



]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> categories [
	^categories
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> className [
	^className
]

{
	#category : 'Initialize-Release',
	#vaVisibility : 'private'
}
TonelReaderMethodDefinition >> initializeClassName: nameString classSide: aBoolean categories: aCollection stamp: stampString [

	className := nameString.
	classSide := aBoolean.
	categories := aCollection.
	stamp := stampString.
	public := true
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> isClassSide [
	^classSide
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> isPrivate [
	^public not
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> isPublic [
	^public
]

{
	#category : 'Printing'
}
TonelReaderMethodDefinition >> printIdentifierOn: aStream [

		aStream 
			nextPut: $[;
			nextPut: $#;
			nextPutAll:  self selector;
			nextPut: $]
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> selector [
	^selector ifNil: [selector := self selectorFromSource asSymbol]
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> selector: aSymbol [

	selector := aSymbol
]

{
	#category : 'Internal',
	#vaVisibility : 'private'
}
TonelReaderMethodDefinition >> selectorFromSource [
	| selectorLine tokens  |	
	selectorLine := (self source subStrings: LineDelimiter) first.
	tokens := selectorLine subStrings: $ .
	
	^tokens size <= 2
		ifTrue: [tokens first]
		ifFalse: [
			tokens 
				inject: String new
				into: [:aSelector :aToken | 
					aToken last = $: 
						ifTrue: [aSelector , aToken] 
						ifFalse: [aSelector]]]
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> source [
	^source
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> source: aString [
	source := aString
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> visibility [

	^public
]

{
	#category : 'Accessing'
}
TonelReaderMethodDefinition >> visibility: aBoolean [

	public := aBoolean
]
