Class {
	#name : 'TonelReaderAbstractClassDefinition',
	#superclass : 'TonelReaderDefinition',
	#instVars : [
		'tonelMethods',
		'hasChanges'
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

{ #category : 'testing' }
TonelReaderAbstractClassDefinition >> isSharedPool [
	^false
]

{ #category : 'accessing' }
TonelReaderAbstractClassDefinition >> tonelMethods [

	^tonelMethods
]
