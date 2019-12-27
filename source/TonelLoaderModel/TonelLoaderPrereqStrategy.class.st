Class {
	#name : 'TonelLoaderPrereqStrategy',
	#superclass : 'TonelLoaderStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'lookup' }
TonelLoaderPrereqStrategy >> prerequisitesFor: tonelApplication current: aCollection [

	self subclassResponsibility
]
