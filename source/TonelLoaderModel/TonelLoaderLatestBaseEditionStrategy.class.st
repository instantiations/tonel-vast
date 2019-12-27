Class {
	#name : 'TonelLoaderLatestBaseEditionStrategy',
	#superclass : 'TonelLoaderBaseEditionStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelLoaderLatestBaseEditionStrategy >> selectBaseEditionOf: aTonelSubApplication [

	
	^aTonelSubApplication availableShadows last
]
