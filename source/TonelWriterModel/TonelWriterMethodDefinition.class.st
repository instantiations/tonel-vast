Class {
	#name : 'TonelWriterMethodDefinition',
	#superclass : 'Object',
	#instVars : [
		'category',
		'selector',
		'class'
	],
	#category : 'TonelWriterModel'
}

{
	#category : 'Instance Creation'
}
TonelWriterMethodDefinition class >> uniquelyKnownAs: aSymbol in: aClass categorizedAs: aCategory [

	^self new initializeUniquelyKnownAs: aSymbol in: aClass categorizedAs: aCategory
]

{
	#category : 'Accessing'
}
TonelWriterMethodDefinition >> allCategories [

	^class categoriesFor: selector
]

{
	#category : 'Accessing'
}
TonelWriterMethodDefinition >> category [

	^category
]

{
	#category : 'Accessing'
}
TonelWriterMethodDefinition >> className [

	^class name
]

{
	#category : 'Accessing'
}
TonelWriterMethodDefinition >> compiledMethod [

	^class >> selector
]

{
	#category : 'Defaults'
}
TonelWriterMethodDefinition >> hasDefaultVACategories [
	"If there is only one category, no need to write #vaCategories key as we are
	 already writing #category:.
	 In the case of extension methods the first in allCategories will be the real one in VA
	 while the one of #category will be one with *X compatible with Tonel/Pharo"

	^self allCategories size = 1 and: [self allCategories first printString = self category]
]

{
	#category : 'Defaults'
}
TonelWriterMethodDefinition >> hasDefaultVAVisibility [

	^self visibilityString = 'public'
]

{
	#category : 'Initialization',
	#vaVisibility : 'private'
}
TonelWriterMethodDefinition >> initializeUniquelyKnownAs: aSymbol in: aClass categorizedAs: aCategory [

	class := aClass.
	selector := aSymbol.
	category := aCategory
]

{
	#category : 'Accessing'
}
TonelWriterMethodDefinition >> methodBody [

	| parseTree body bodyStream messagePattern |

	parseTree :=
		EsParser
			parse: self compiledMethod sourceString
			class: self compiledMethod methodClass
			scanComments: false
			errorHandler: nil
			ifFail: [nil].

	messagePattern := parseTree messagePattern.
	bodyStream :=
		(self compiledMethod sourceString
			copyFrom: (messagePattern sourceEnd + (CldtConstants::LineDelimiter size) + 1)
			to: parseTree sourceEnd)
				readStream.
				
	body :=
		bodyStream
			skipSeparators;
			contents.
	^body
]

{
	#category : 'Accessing'
}
TonelWriterMethodDefinition >> methodDeclaration [

	| parseTree declaration messagePattern |

	parseTree :=
		EsParser
			parse: self compiledMethod sourceString
			class: self compiledMethod methodClass
			scanComments: false
			errorHandler: nil
			ifFail: [nil].
	messagePattern := parseTree messagePattern.
	declaration := messagePattern asString trimBoth: [:char | char isSeparator].
	^declaration
]

{
	#category : 'Accessing'
}
TonelWriterMethodDefinition >> visibilityString [

	^self compiledMethod isPrivate ifTrue: ['private'] ifFalse: ['public']
]
