Class {
	#name : 'TonelWriterTests',
	#superclass : 'Application',
	#category : 'TonelWriterTests'
}

{
	#category : 'Testing'
}
TonelWriterTests class >> exceptionsForClassesWithoutProtocol [

	^Array with: TonelMockB with: TonelMockC with: TonelMockE
]
