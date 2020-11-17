Class {
	#name : 'TonelLoaderTestClassB',
	#superclass : 'Object',
	#category : 'TonelLoaderTestApplication'
}

{ #category : 'Not categorized' }
TonelLoaderTestClassB class >> _PRAGMA_TonelLoaderTestPoolDictionaryA [

	"%%PRAGMA DECLARE   
(name: TonelLoaderTestPoolDictionaryA isPool: true)
		(pool: TonelLoaderTestPoolDictionaryA declarations: (

		(name: TLTPD_A isConstant: true valueExpression: '1')
		(name: TLTPD_B isConstant: true valueExpression: '2')
		(name: TLTPD_C isConstant: true valueExpression: '3')
		))"


]

{ #category : 'Not categorized' }
TonelLoaderTestClassB >> baz [

	^#(1 2 3)
]
