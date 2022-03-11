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
	"Answers the identifier of receiver."

	self subclassResponsibility
]

{ #category : 'testing' }
TonelReaderAbstractClassDefinition >> isSharedPool [
	"Answer whether receiver represents a shared pool class."

	^false
]

{ #category : 'accessing' }
TonelReaderAbstractClassDefinition >> tonelMethods [
	"Returns a collection of TonelReaderMethodDefinition."

	^tonelMethods
]
