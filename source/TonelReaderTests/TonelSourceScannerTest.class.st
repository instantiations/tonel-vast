Class {
	#name : 'TonelSourceScannerTest',
	#superclass : 'TestCase',
	#category : 'TonelReaderTests'
}

{
	#category : 'instance creation'
}
TonelSourceScannerTest class >> new [

	^super new initialize
]

{
	#category : 'tests'
}
TonelSourceScannerTest >> testScan [

	| scanner |

	scanner := TonelSourceScanner on: '[^'''']' readStream.
	self assert: scanner scan equals: '^'''''.
	scanner :=
		TonelSourceScanner on:
			'[
	self 
		at: Object1 put: ''one string'';
		at: Object2 put: ''other string'';
		yourself
]'
				readStream.
	self
		assert: scanner scan
		equals:
			'
	self 
		at: Object1 put: ''one string'';
		at: Object2 put: ''other string'';
		yourself'
]

{
	#category : 'tests'
}
TonelSourceScannerTest >> testScanForComment [
	| scanner |
	scanner := TonelSourceScanner on: '""' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForComment.
	self assert: (scanner instVarNamed: 'result') contents equals: '""'.
	scanner := TonelSourceScanner on: '"simple comment"' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForComment.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '"simple comment"'.
	scanner := TonelSourceScanner
		on:
			'"multiline 
comment"' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForComment.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals:
			'"multiline 
comment"'.
	scanner := TonelSourceScanner
		on: '"simple comment with "" colons inside"' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForComment.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '"simple comment with "" colons inside"'.
	scanner := TonelSourceScanner
		on: '"simple comment with colons at the end"""' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForComment.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '"simple comment with colons at the end"""'
]

{
	#category : 'tests'
}
TonelSourceScannerTest >> testScanForLiteralArray [
	| scanner |
	scanner := TonelSourceScanner on: '#()' readStream.
	scanner prepareToScan.
	scanner
		readNext;
		readNext.
	scanner scanForLiteralArray.
	self assert: (scanner instVarNamed: 'result') contents equals: '#()'.
	scanner := TonelSourceScanner on: '#(a b c)' readStream.
	scanner prepareToScan.
	scanner
		readNext;
		readNext.
	scanner scanForLiteralArray.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '#(a b c)'.
	scanner := TonelSourceScanner on: '#((a b) c)' readStream.
	scanner prepareToScan.
	scanner
		readNext;
		readNext.
	scanner scanForLiteralArray.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '#((a b) c)'.
	scanner := TonelSourceScanner on: '#((a (b)) c)' readStream.
	scanner prepareToScan.
	scanner
		readNext;
		readNext.
	scanner scanForLiteralArray.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '#((a (b)) c)'.
	scanner := TonelSourceScanner on: '#(a (b c))' readStream.
	scanner prepareToScan.
	scanner
		readNext;
		readNext.
	scanner scanForLiteralArray.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '#(a (b c))'
]

{
	#category : 'tests'
}
TonelSourceScannerTest >> testScanForString [
	| scanner |
	scanner := TonelSourceScanner on: '''-.*$''' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForString.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '''-.*$'''.
	scanner := TonelSourceScanner
		on: '''simple comment ''''with'''' colons enclosing word''' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForString.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '''simple comment ''''with'''' colons enclosing word'''.
	scanner := TonelSourceScanner on: '''''' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForString.
	self assert: (scanner instVarNamed: 'result') contents equals: ''''''.
	scanner := TonelSourceScanner on: '''simple string''' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForString.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '''simple string'''.
	scanner := TonelSourceScanner
		on:
			'''multiline 
string''' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForString.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals:
			'''multiline 
string'''.
	scanner := TonelSourceScanner
		on: '''simple string with '''' colons inside''' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForString.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '''simple string with '''' colons inside'''.
	scanner := TonelSourceScanner
		on: '''simple string with colons at the end''''' readStream.
	scanner prepareToScan.
	scanner readNext.
	scanner scanForString.
	self
		assert: (scanner instVarNamed: 'result') contents
		equals: '''simple string with colons at the end'''''
]

{
	#category : 'tests'
}
TonelSourceScannerTest >> testScanMethodWithLotsOfSpecials [

	| scanner |

	scanner :=
		TonelSourceScanner on:
			'[
	"Do not allow whitespace between # and the literal."

	"Do not allow number literals after the #"

	self step.
	characterType = #alphabetic
		ifTrue: [ ^ self scanSymbol ].
	characterType = #binary
		ifTrue:
			[ ^ (self scanBinary: RBLiteralToken)
				stop: self previousStepPosition ].
	currentCharacter = $''
		ifTrue: [ ^ self scanStringSymbol ].
	(currentCharacter = $( or: [ currentCharacter = $[ ])
		ifTrue: [ ^ self scanLiteralArrayToken ].
	"Accept multiple #."
	currentCharacter = $#
		ifTrue: [ ^ self scanLiteral ].
	^ self scanError: ''Expecting a literal type''
]'
				readStream.
	self
		assert: scanner scan
		equals:
			'
	"Do not allow whitespace between # and the literal."

	"Do not allow number literals after the #"

	self step.
	characterType = #alphabetic
		ifTrue: [ ^ self scanSymbol ].
	characterType = #binary
		ifTrue:
			[ ^ (self scanBinary: RBLiteralToken)
				stop: self previousStepPosition ].
	currentCharacter = $''
		ifTrue: [ ^ self scanStringSymbol ].
	(currentCharacter = $( or: [ currentCharacter = $[ ])
		ifTrue: [ ^ self scanLiteralArrayToken ].
	"Accept multiple #."
	currentCharacter = $#
		ifTrue: [ ^ self scanLiteral ].
	^ self scanError: ''Expecting a literal type'''
]

{
	#category : 'tests'
}
TonelSourceScannerTest >> testScanMethodWithParserErrors [
	| scanner |
	scanner := TonelSourceScanner
		on:
			'[#(#(''self foo. + 3'' 11) #(''#('' 3) #(''self 0'' 6) #(''self asdf;;asfd'' 11))]'
				readStream.
	self
		assert: scanner scan
		equals:
			'#(#(''self foo. + 3'' 11) #(''#('' 3) #(''self 0'' 6) #(''self asdf;;asfd'' 11))'
]

{
	#category : 'tests'
}
TonelSourceScannerTest >> testScanMethodWithTerminatingBrackets [
	| scanner |
	scanner := TonelSourceScanner on: '[[''-.*$'']]' readStream.
	self assert: scanner scan equals: '[''-.*$'']'
]
