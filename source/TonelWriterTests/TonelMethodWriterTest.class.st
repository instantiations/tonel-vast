Class {
	#name : 'TonelMethodWriterTest',
	#superclass : 'TonelBaseTest',
	#category : 'TonelWriterTests'
}

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
TonelMethodWriterTest >> testWriteMethodDefinitionAsIs [

	| definition stream |

	definition :=
		TonelWriterMethodDefinition
			uniquelyKnownAs: #withSpacesInsteadOfTabs
			in: TonelMockA
			categorizedAs: 'Accessing'.
	stream := self newStream.
	writer write: definition on: stream.
	self
		assert: stream contents
		isEqualSkippingSeparatorsTo:
		'{	#category : ''Accessing'' }
TonelMockA >> withSpacesInsteadOfTabs [

	^''{
  "foo": 1,
  "baz": true
  }''
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
TonelMethodWriterTest >> testWriteMethodWithMultipleCategories [

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
{
	#category : ''Accessing'',
	 #vaCategories : [''Accessing'',''Evaluating'',''Private'']
}
TonelMockA >> withMultipleCategories [

	^''withMultipleCategories''
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
