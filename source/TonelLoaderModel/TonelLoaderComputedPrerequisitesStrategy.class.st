Class {
	#name : 'TonelLoaderComputedPrerequisitesStrategy',
	#superclass : 'TonelLoaderApplicationPrereqStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'lookup' }
TonelLoaderComputedPrerequisitesStrategy >> prerequisitesFor: tonelApplication current: aCollection [

	^tonelApplication prerequisites
]
