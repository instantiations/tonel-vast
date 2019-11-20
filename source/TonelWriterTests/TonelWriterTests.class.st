Class {
	#name : 'TonelWriterTests',
	#superclass : 'Application',
	#pools : [
		'TonelTestsConstants'
	],
	#category : 'TonelWriterTests'
}

{ #category : 'Testing' }
TonelWriterTests class >> exceptionsForClassesWithoutProtocol [

	^Array with: TonelMockB with: TonelMockC with: TonelMockE
]
