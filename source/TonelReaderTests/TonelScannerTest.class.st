Class {
	#name : 'TonelScannerTest',
	#superclass : 'TestCase',
	#category : 'TonelReaderTests'
}

{ #category : 'instance creation' }
TonelScannerTest class >> new [

	^super new initialize
]

{ #category : 'tests' }
TonelScannerTest >> testRemoveFromEnclosingStartEnd [
	| scanner nl |
	nl := CldtConstants::LineDelimiter.
	scanner := TonelScanner basicNew.
	self
		assert:
			(scanner removeFrom: '[ ^ self ]' enclosingStart: $[ end: $])
		equals: '^ self'.
	self
		assert:
			(scanner
				removeFrom:
					('[ 
	^ self ]' withLineEndings: nl)
				enclosingStart: $[
				end: $])
		equals: Character tab asString , '^ self'.
	self
		assert:
			(scanner
				removeFrom:
					('[ 
	^ self
	]' withLineEndings: nl)
				enclosingStart: $[
				end: $])
		equals: Character tab asString , '^ self'.
	self
		assert:
			(scanner
				removeFrom:
					('[ 

	^ self

]' withLineEndings: nl)
				enclosingStart: $[
				end: $])
		equals:
			('
	^ self
' withLineEndings: nl)
]
