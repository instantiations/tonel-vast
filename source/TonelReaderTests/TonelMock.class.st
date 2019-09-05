"
Description
--------------------

I am a simple Mock for Tonel export test
"
Class {
	#name : 'TonelMock',
	#superclass : 'Object',
	#category : 'TonelReaderTests'
}

{
	#category : 'accessing'
}
TonelMock class >> classMethod [
	^ 8
]

{
	#category : 'instance creation'
}
TonelMock class >> new [

	^super new initialize
]

{
	#category : 'accessing'
}
TonelMock >> instanceMethod [
	^ true
]
