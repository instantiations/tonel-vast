Class {
	#name : 'TonelLoaderComputedPrerequisitesStrategy',
	#superclass : 'TonelLoaderPrereqStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'lookup' }
TonelLoaderComputedPrerequisitesStrategy >> prerequisitesFor: tonelApplication current: aCollection [

	^tonelApplication prerequisites
]
