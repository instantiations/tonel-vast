Class {
	#name : 'TonelMethodWriter',
	#superclass : 'Object',
	#instVars : [
		'tab',
		'space',
		'lineDelimiter',
		'parent'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Instance Creation' }
TonelMethodWriter class >> in: aTonelWriter [

	^self new initializeIn: aTonelWriter
]

{ #category : 'Instance Creation' }
TonelMethodWriter class >> new [

	^super new initialize
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelMethodWriter >> initializeIn: aTonelWriter [

	super initialize.
	tab := Character tab.
	space := Character space.
	lineDelimiter := aTonelWriter lineDelimiter.
	parent := aTonelWriter
]

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelMethodWriter >> normalizeMethodBody: aBodyString [

	| normalized |

	normalized := aBodyString copyReplaceAll: CldtConstants::LineDelimiter with: lineDelimiter.
	^normalized
]

{ #category : 'Not categorized' }
TonelMethodWriter >> parent [
	"Answer the parent TonelWriter of receiver."

	^parent
]

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelMethodWriter >> splitSourceOf: aMethodDefinition into: aBlock [

	^aBlock value: aMethodDefinition methodDeclaration value: aMethodDefinition methodBody
]

{ #category : 'writing' }
TonelMethodWriter >> write: aMethodDefinition on: aWriteStream [

	self
		splitSourceOf: aMethodDefinition
		into: [:methodDeclaration :methodBody | | normalizedBody |
			normalizedBody := self normalizeMethodBody: methodBody.
			aWriteStream << lineDelimiter << '{'.
			self writeCategoryOf: aMethodDefinition on: aWriteStream.
			self writeVACategoriesOf: aMethodDefinition on: aWriteStream.
			self writeVAVisibilityOf: aMethodDefinition on: aWriteStream.
			aWriteStream << space << '}' << lineDelimiter << aMethodDefinition definitionClassName <<
				' >> ' << methodDeclaration << ' [' << lineDelimiter << normalizedBody <<
				lineDelimiter << ']' << lineDelimiter]
]

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelMethodWriter >> writeCategoryOf: aMethodDefinition on: aWriteStream [

	aWriteStream << space << '#category : ' << aMethodDefinition category storeString
]

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelMethodWriter >> writeVACategoriesOf: aMethodDefinition on: aWriteStream [

	| categories |

	aMethodDefinition hasDefaultVACategories
		ifFalse: [
			aWriteStream << ',' << lineDelimiter << space << '#vaCategories : '.
			categories := aMethodDefinition allCategories asSortedCollection.
			aWriteStream nextPut: $[.
			categories
				do: [:each | aWriteStream nextPutAll: each printString]
				separatedBy: [aWriteStream nextPut: $,].
			aWriteStream nextPut: $]]


]

{ #category : 'writing',
  #vaVisibility : 'private' }
TonelMethodWriter >> writeVAVisibilityOf: aMethodDefinition on: aWriteStream [

	aMethodDefinition hasDefaultVAVisibility
		ifFalse: [
			aWriteStream << ',' << lineDelimiter << space << space << '#vaVisibility : ' <<
				aMethodDefinition visibilityString printString]
]
