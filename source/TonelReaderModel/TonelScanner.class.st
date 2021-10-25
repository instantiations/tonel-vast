"
I'm a generic scanner to help on parsing tonel files.
"
Class {
	#name : 'TonelScanner',
	#superclass : 'Object',
	#instVars : [
		'stream'
	],
	#category : 'TonelReaderModel'
}

{ #category : 'instance creation' }
TonelScanner class >> new [
	self error: 'Use #on:'
]

{ #category : 'instance creation' }
TonelScanner class >> on: aStream [
	^ self basicNew
		initializeStream: aStream;
		yourself
]

{ #category : 'initialization' }
TonelScanner >> initializeStream: aStream [
	self initialize.
	stream := aStream
]

{ #category : 'testing' }
TonelScanner >> isEnter: aCharacter [
	^ #(13 10) includes: aCharacter value
]

{ #category : 'testing' }
TonelScanner >> isSeparator: aCharacter [
	^ aCharacter isSeparator
]

{ #category : 'private' }
TonelScanner >> removeFrom: aString enclosingStart: startChar end: endChar [
	^ self
		removeFrom: aString
		enclosingStart: startChar
		end: endChar
		clean: #both
]

{ #category : 'private',
  #vaVisibility : 'private' }
TonelScanner >> removeFrom: aString enclosingStart: startChar end: endChar clean: cleanSymbol [
	"cleanSymbol can be #left, #right and #both"

	| nl result stop ch start end |
	nl := CldtConstants::LineDelimiter.
	result := ((aString trimBoth: [ :char | char isSeparator ]) tonelWithLineEndings: nl) readStream.
	result peek = startChar
		ifFalse: [ TonelParseError signal: 'I cannot remove enclosing start' ].
	result skip: 1.
	(#(both left) includes: cleanSymbol)
		ifTrue: [ stop := nl size.
			[ stop > 0 and: [ self isSeparator: (ch := result peek) ] ]
				whileTrue: [ (self isEnter: ch)
						ifTrue: [ stop := stop - 1 ].
					result skip: 1 ] ].
	start := result position.
	result setToEnd.
	result skip: -1.
	result peek = endChar
		ifFalse: [ TonelParseError signal: 'I cannot remove enclosing end' ].
	result skip: -1.
	(#(both right) includes: cleanSymbol)
		ifTrue: [ stop := nl size.
			[ stop > 0 and: [ self isSeparator: (ch := result peek) ] ]
				whileTrue: [ (self isEnter: ch)
						ifTrue: [ stop := stop - 1 ].
					result skip: -1 ] ].
	end := result position.
	^ result contents copyFrom: start + 1 to: end + 1
]

{ #category : 'scanning' }
TonelScanner >> scan [
	self subclassResponsibility
]
