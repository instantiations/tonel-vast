Class {
	#name : 'TonelLoaderNamingStrategy',
	#superclass : 'TonelLoaderStrategy',
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'resolving' }
TonelLoaderNamingStrategy >> appNameWithoutSuffix: aTonelLoaderApplication [

	self subclassResponsibility
]

{ #category : 'resolving' }
TonelLoaderNamingStrategy >> nameForApp: aTonelLoaderApplication [

	self subclassResponsibility

]

{ #category : 'resolving' }
TonelLoaderNamingStrategy >> nameForSubApp: aTonelLoaderSubApplication [

	self subclassResponsibility

]
