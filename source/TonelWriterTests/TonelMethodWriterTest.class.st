Class {
	#name : 'TonelMethodWriterTest',
	#superclass : 'TonelBaseTest',
	#category : 'TonelWriterTests'
}

{ #category : 'Initialization' }
TonelMethodWriterTest >> expectedFailures [
	"Answer a collection of selectors in a test that are expected to fail.
	 This provides the capability to mask expected failures so they do not
	 need to be examined on each test run."
	
	^ #(testWriteMethodDefinitionWithCommmentInSelectorLine)
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelMethodWriterTest >> newStream [

	^TonelUTF8StreamWriterWrapper wrapping: String new writeStream
]

{ #category : 'Initialization' }
TonelMethodWriterTest >> setUp [

	super setUp.
	writer := TonelMethodWriter in: TonelWriter new
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteClassMethodDefinition [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #isTonelMock
			in: TonelMockA class
			categorizedAs: 'Testing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		isEqualSkippingSeparatorsTo:
			'
{
	#category : ''Testing''
}
TonelMockA class >> isTonelMock [

	^true
]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteMethodDefinition [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #denominator
			in: TonelMockA
			categorizedAs: 'Accessing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		isEqualSkippingSeparatorsTo:
			'
{
	#category : ''Accessing''
}
TonelMockA >> denominator [

	^denominator
]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteMethodDefinitionWithBinaryMessage [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #value
			in: TonelMockA
			categorizedAs: 'Evaluating'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		isEqualSkippingSeparatorsTo:
			'
{
	#category : ''Evaluating''
}
TonelMockA >> value [

	^numerator / denominator
]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteMethodDefinitionWithCommment [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #withComment
			in: TonelMockA
			categorizedAs: 'Accessing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		isEqualSkippingSeparatorsTo:
			'
{
	#category : ''Accessing''
}
TonelMockA >> withComment [
	"This is a mock method being used within the tests of Tonel"

	^''Method with comment''
]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteMethodDefinitionWithCommmentInSelectorLine [
	"This test might require modifying the source of the method TonelMockA>>#withCommentOnSelectorLine, 
	 because it is automatically corrected when loaded back from a Tonel repository."

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #withCommentOnSelectorLine
			in: TonelMockA
			categorizedAs: 'Accessing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		equals:
			'
{ #category : ''Accessing'' }
TonelMockA >> withCommentOnSelectorLine [
"This is a mock method being used within the tests of Tonel"

	^''Method with comment on the same line as selector''
]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteMethodDefinitionWithCommmentWithoutExtraLine [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #withComment
			in: TonelMockA
			categorizedAs: 'Accessing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		equals:
			'
{ #category : ''Accessing'' }
TonelMockA >> withComment [
	"This is a mock method being used within the tests of Tonel"

	^''Method with comment''
]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteMethodDefinitionWithLocalVariable [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #withLocalVariable
			in: TonelMockA
			categorizedAs: 'Accessing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		isEqualSkippingSeparatorsTo:
			'
{
	#category : ''Accessing''
}
TonelMockA >> withLocalVariable [

	| localVariable |

	localVariable := ''tonel'' reverse.

	^localVariable
]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteMethodDefinitionWithMoreThanOneLine [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #withModeThanOneLine
			in: TonelMockA
			categorizedAs: 'Accessing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		isEqualSkippingSeparatorsTo:
		'
{
	#category : ''Accessing''
}
TonelMockA >> withModeThanOneLine [

	^(self value > 4) 
		ifTrue: [denominator / 2 ] 
		ifFalse: [numerator]
]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteMethodDefinitionWithMultipleCategories [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #withMultipleCategories
			in: TonelMockA
			categorizedAs: 'Accessing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		isEqualSkippingSeparatorsTo:
			'
{ #category : ''Accessing'',
	#vaCategories : [''Accessing'', ''Evaluating'', ''Good\''ol quoted category'', ''Private''] }
TonelMockA >> withMultipleCategories [

	^ ''withMultipleCategories''
]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWriteMethodDefinitionWithNoBody [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #withNoBody
			in: TonelMockA
			categorizedAs: 'Accessing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		equals:
			'
{ #category : ''Accessing'' }
TonelMockA >> withNoBody [

]
'
]

{ #category : 'Test' }
TonelMethodWriterTest >> testWritePrivateMethodDefinition [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #privateMethod
			in: TonelMockA
			categorizedAs: 'Private'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		isEqualSkippingSeparatorsTo:
			'
{
	#category : ''Private'',
	#vaVisibility : ''private''
}
TonelMockA >> privateMethod [

	^''privateMethod''
]
'
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelMethodWriterTest >> wrapBetweenSingleQuotes: aString [

	^String streamContents: [:stream |
		stream
			nextPut: $';
			nextPutAll: aString;
			nextPut: $']
]
