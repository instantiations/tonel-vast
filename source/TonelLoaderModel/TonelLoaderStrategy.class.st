Class {
	#name : 'TonelLoaderStrategy',
	#superclass : 'Object',
	#instVars : [
		'loader'
	],
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'instance creation' }
TonelLoaderStrategy class >> for: aTonelLoader [

	^self new
		setLoader: aTonelLoader;
		yourself
]

{ #category : 'instance creation' }
TonelLoaderStrategy class >> new [

	^super new initialize
]

{ #category : 'initializing' }
TonelLoaderStrategy >> loader [

	^loader
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderStrategy >> setLoader: aTonelLoader [

	loader := aTonelLoader
]
