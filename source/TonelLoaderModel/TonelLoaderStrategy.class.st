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

	^self basicNew
		setLoader: aTonelLoader;
		yourself
]

{ #category : 'instance creation' }
TonelLoaderStrategy class >> new [

	^super new initialize
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderStrategy >> copyFor: aTonelLoader [

	^self copy
		setLoader: aTonelLoader;
		yourself
]

{ #category : 'accessing' }
TonelLoaderStrategy >> loader [

	^loader
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderStrategy >> setLoader: aTonelLoader [

	loader := aTonelLoader.
	self initialize
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderStrategy >> stringClass [

	^Locale current preferredStringClass
]
