Class {
	#name : 'TonelReaderAbstractClassDefinition',
	#superclass : 'TonelReaderDefinition',
	#instVars : [
		'tonelMethods'
	],
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelReaderModel'
}

{ #category : 'accessing' }
TonelReaderAbstractClassDefinition >> identifier [

	self subclassResponsibility
]

{ #category : 'accessing' }
TonelReaderAbstractClassDefinition >> tonelMethods [

	^tonelMethods
]
