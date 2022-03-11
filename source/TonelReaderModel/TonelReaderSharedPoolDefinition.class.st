Class {
	#name : 'TonelReaderSharedPoolDefinition',
	#superclass : 'TonelReaderClassDefinition',
	#category : 'TonelReaderModel'
}

{ #category : 'Not categorized' }
TonelReaderSharedPoolDefinition >> createEditionIn: anApp using: aTonelLoader [
	"Creates an edition for receiver in anApp (or Subapp) using aTonelLoader.
	 Since shared pools are not defined as classes and are defined elsewhere, we do nothing."

]

{ #category : 'Not categorized' }
TonelReaderSharedPoolDefinition >> isSharedPool [
	^true
]
