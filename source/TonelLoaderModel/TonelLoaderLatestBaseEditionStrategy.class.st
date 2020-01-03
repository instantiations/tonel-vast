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

{ #category : 'operations' }
TonelLoaderLatestBaseEditionStrategy >> selectPrerequisiteEditionOf: application in: prereqs using: browser at: cursorPosition [

	^prereqs isEmpty ifFalse: [(prereqs asSortedCollection: [:a :b | a timeStamp <= b timeStamp]) first ]
]
