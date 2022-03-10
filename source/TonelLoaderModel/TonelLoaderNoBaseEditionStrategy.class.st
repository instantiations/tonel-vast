Class {
	#name : 'TonelLoaderNoBaseEditionStrategy',
	#superclass : 'TonelLoaderBaseEditionStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelLoaderNoBaseEditionStrategy >> hasSelectableBaseEditionFor: tonelAppOrSub [
	"Answer whether there is an edition for aTonelAppOrSubApp
	 that can be used its base edition.
	 
	 Receiver will always return false."
	
	^false
]
