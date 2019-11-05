Class {
	#name : 'TonelMethodWriter',
	#superclass : 'Object',
	#instVars : [
		'tab',
		'lineDelimiter'
	],
	#category : 'TonelWriterModel'
}

{
	#category : 'Instance Creation'
}
TonelMethodWriter class >> new [

	^super new initialize
]

{
	#category : 'Instance Creation'
}
TonelMethodWriter class >> with: aLineDelimiter [

	^self new initializeWith: aLineDelimiter
]

{
	#category : 'Initialization',
	#vaVisibility : 'private'
}
TonelMethodWriter >> initializeWith: aLineDelimiter [

	super initialize.
	tab := Character tab.
	lineDelimiter := aLineDelimiter
]

{
	#category : 'Writing',
	#vaVisibility : 'private'
}
TonelMethodWriter >> normalizeMethodBody: aBodyString [

	| normalized |

	normalized := aBodyString copyReplaceAll: CldtConstants::LineDelimiter with: lineDelimiter.
	^normalized
]

{
	#category : 'Writing',
	#vaVisibility : 'private'
}
TonelMethodWriter >> splitSourceOf: aMethodDefinition into: aBlock [

	^aBlock value: aMethodDefinition methodDeclaration value: aMethodDefinition methodBody
]

{
	#category : 'Writing'
}
TonelMethodWriter >> write: aMethodDefinition on: aWriteStream [

	self
		splitSourceOf: aMethodDefinition
		into: [:methodDeclaration :methodBody | | normalizedBody |
			normalizedBody := self normalizeMethodBody: methodBody.
			aWriteStream << lineDelimiter << '{'.
			self writeCategoryOf: aMethodDefinition on: aWriteStream.
			self writeVACategoriesOf: aMethodDefinition on: aWriteStream.
			self writeVAVisibilityOf: aMethodDefinition on: aWriteStream.
			aWriteStream << lineDelimiter << '}' << lineDelimiter << aMethodDefinition definitionClassName <<
				' >> ' << methodDeclaration << ' [' << lineDelimiter << normalizedBody <<
				lineDelimiter << ']' << lineDelimiter]
]

{
	#category : 'Writing',
	#vaVisibility : 'private'
}
TonelMethodWriter >> writeCategoryOf: aMethodDefinition on: aWriteStream [

	aWriteStream << lineDelimiter << tab << '#category : ' << aMethodDefinition category
]

{
	#category : 'Writing',
	#vaVisibility : 'private'
}
TonelMethodWriter >> writeVACategoriesOf: aMethodDefinition on: aWriteStream [

	| categories |

	aMethodDefinition hasDefaultVACategories
		ifFalse: [
			aWriteStream << ',' << lineDelimiter << tab << '#vaCategories : '.
			categories := aMethodDefinition allCategories asSortedCollection.
			aWriteStream nextPut: $[.
			categories
				do: [:each | aWriteStream nextPutAll: each printString]
				separatedBy: [aWriteStream nextPut: $,].
			aWriteStream nextPut: $]]


]

{
	#category : 'Writing',
	#vaVisibility : 'private'
}
TonelMethodWriter >> writeVAVisibilityOf: aMethodDefinition on: aWriteStream [

	aMethodDefinition hasDefaultVAVisibility
		ifFalse: [
			aWriteStream << ',' << lineDelimiter << tab << '#vaVisibility : ' <<
				aMethodDefinition visibilityString printString]
]
