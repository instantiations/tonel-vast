"
Class comment for tests
"
Class {
	#name : 'TonelMockA',
	#superclass : 'Object',
	#instVars : [
		'numerator',
		'denominator'
	],
	#classVars : [
		'ClassVar'
	],
	#category : 'TonelWriterTests'
}

{ #category : 'Accessing' }
TonelMockA class >> classVar [

	ClassVar := 1
]

{ #category : 'Testing' }
TonelMockA class >> isTonelMock [

	^true
]

{ #category : 'Accessing' }
TonelMockA >> denominator [

	^denominator
]

{ #category : 'Private',
  #vaVisibility : 'private' }
TonelMockA >> privateMethod [

	^'privateMethod'
]

{ #category : 'Evaluating' }
TonelMockA >> value [

	^numerator / denominator
]

{ #category : 'Accessing' }
TonelMockA >> withComment [
	"This is a mock method being used within the tests of Tonel"

	^'Method with comment'
]

{ #category : 'Accessing' }
TonelMockA >> withCommentOnSelectorLine [
"This is a mock method being used within the tests of Tonel"

	^'Method with comment on the same line as selector'
]

{ #category : 'Accessing' }
TonelMockA >> withDenominatorDo: aDyadicBlock [

	^aDyadicBlock value: denominator
]

{ #category : 'Accessing' }
TonelMockA >> withLocalVariable [

	| localVariable |

	localVariable := 'tonel' reverse.

	^localVariable
]

{ #category : 'Accessing' }
TonelMockA >> withModeThanOneLine [

	^(self value > 4) 
		ifTrue: [denominator / 2 ] 
		ifFalse: [numerator]
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','Evaluating','Good\'ol quoted category','Private'] }
TonelMockA >> withMultipleCategories [

	^ 'withMultipleCategories'
]

{ #category : 'Accessing' }
TonelMockA >> withNoBody [

]
