"
I'm a scanner to get correct sources from method definitions in Tonel format.

Implementation details:
Method body is delineated by square brackets in Tonel format, thus I just have to detect enclosing square brackets [].
Since a method body can include nested blocks and ByteArray literals, I have to maintain a count of opened and closed brackets in order to correctly detect the end of method body.
But method body can also contain isolated brackets (which are not necessarily paired) in following patterns:
		- comments like ""[""
		- strings like ']'
		- array literals like #( [ )
		- literal characters like $] 
Therefore, I need to be aware of syntax for the four cases above, in order to correctly skip those potentially isolated brackets.
"
Class {
	#name : 'TonelSourceScanner',
	#superclass : 'TonelScanner',
	#instVars : [
		'char',
		'prevChar',
		'result',
		'count',
		'isFinished'
	],
	#category : 'TonelReaderModel'
}

{ #category : 'testing' }
TonelSourceScanner >> isStartingComment [
	"Comment start with a double quote in Smalltalk syntax"

	^ char = $"
]

{ #category : 'testing' }
TonelSourceScanner >> isStartingLiteralArray [
	"Literal array starts with a sharp sign followed by parenthesis in Smalltalk syntax"

	^ char = $( and: [ prevChar = $# ]
]

{ #category : 'testing' }
TonelSourceScanner >> isStartingLiteralCharacter [
	"A literal Character start with a dollar sign in Smalltalk syntax"

	^ char = $$
]

{ #category : 'testing' }
TonelSourceScanner >> isStartingString [
	"String start with single quote in Smalltalk syntax"

	^ char = $'
]

{ #category : 'private' }
TonelSourceScanner >> prepareToScan [
	result := String new writeStream.
	isFinished := false.
	char := prevChar := nil.
	count := 0
]

{ #category : 'private' }
TonelSourceScanner >> readNext [
	prevChar := char.
	result nextPut: (char := stream next)
]

{ #category : 'private' }
TonelSourceScanner >> readUntil: aBlock [
	[ stream atEnd ]
		whileFalse: [ self readNext.
			aBlock value
				ifTrue: [ ^ self ] ]
]

{ #category : 'private' }
TonelSourceScanner >> readUntilTermination: matchChar [
	| terminationCount |
	"This is used to read sequences that start and finish with same character termination. 
	 tipically, this is for strings and comments, but who knows what comes in the future."
	terminationCount := 1.
	self
		readUntil: [ char = matchChar
				ifTrue: [ terminationCount := terminationCount + 1 ].
			terminationCount even and: [ stream peek ~= matchChar ] ]
]

{ #category : 'scanning' }
TonelSourceScanner >> scan [

	self prepareToScan.
	stream peek = $[ ifFalse: [TonelParseError signal: 'Can''t parse method body'].
	[stream atEnd or: [isFinished]] whileFalse: [self scanNextChunk].
	isFinished
		ifTrue: [ "clean up to return"
			^self removeFrom: result contents enclosingStart: $[ end: $] clean: #right].
	TonelParseError signal: 'Can''t parse method body'
]

{ #category : 'scanning' }
TonelSourceScanner >> scanForBlock [
	| match |
	match := false.
	char = $[
		ifTrue: [ count := count + 1.
			match := true ].
	char = $]
		ifTrue: [ count := count - 1.
			match := true ].
	isFinished := count = 0.
	^ match
]

{ #category : 'scanning' }
TonelSourceScanner >> scanForComment [
	self isStartingComment
		ifFalse: [ ^ false ].
	self readUntilTermination: $".
	^ true
]

{ #category : 'scanning' }
TonelSourceScanner >> scanForLiteralArray [
	| literalCount |
	self isStartingLiteralArray
		ifFalse: [ ^ false ].
	literalCount := 1.
	self
		readUntil: [ self scanForLiteralCharacter
				or: [ self scanForString
						or: [ self scanForComment
								or: [ char = $(
										ifTrue: [ literalCount := literalCount + 1 ].
									char = $)
										ifTrue: [ literalCount := literalCount - 1 ] ] ] ].
			literalCount = 0 ].
	^ true
]

{ #category : 'scanning' }
TonelSourceScanner >> scanForLiteralCharacter [
	self isStartingLiteralCharacter
		ifFalse: [ ^ false ].
	self readNext.
	^ true
]

{ #category : 'scanning' }
TonelSourceScanner >> scanForString [
	self isStartingString
		ifFalse: [ ^ false ].
	self readUntilTermination: $'.
	^ true
]

{ #category : 'scanning' }
TonelSourceScanner >> scanNextChunk [
	self readNext.
	self scanForBlock
		or: [ self scanForComment
				or: [ self scanForString
						or: [ self scanForLiteralCharacter or: [ self scanForLiteralArray ] ] ] ]
]
