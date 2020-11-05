Class {
	#name : 'TonelLoaderLatestBaseEditionStrategy',
	#superclass : 'TonelLoaderBaseEditionStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelLoaderLatestBaseEditionStrategy >> selectBaseEditionOf: aTonelApplication [

	| shadows |

	^(shadows := self filteredBaseEditions: aTonelApplication availableShadows) isEmpty
		ifTrue: [nil]
		ifFalse: [shadows first]
]

{ #category : 'operations' }
TonelLoaderLatestBaseEditionStrategy >> selectPrerequisiteEditionOf: application in: prereqs [

	^prereqs isEmpty 
		ifFalse: 
			[(prereqs asSortedCollection: [:a :b | a timeStamp <= b timeStamp]) first]
]
