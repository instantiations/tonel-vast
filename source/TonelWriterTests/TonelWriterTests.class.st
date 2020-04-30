Class {
	#name : 'TonelWriterTests',
	#superclass : 'Application',
	#pools : [
		'TonelTestsConstants'
	],
	#category : 'TonelWriterTests'
}

{ #category : 'Pools' }
TonelWriterTests class >> _PRAGMA_TonelTestsConstants [


"%%PRAGMA DECLARE
	(name: TonelTestsConstants isPool: true)
	(pool: TonelTestsConstants declarations: (
		(name: Constant1 isConstant: true valueExpression: '1')
		(name: Constant2 isConstant: true valueExpression: '2')
	
	))
	"
]

{ #category : 'Testing' }
TonelWriterTests class >> exceptionsForClassesWithoutProtocol [

	^Array with: TonelMockB with: TonelMockC with: TonelMockE
]
