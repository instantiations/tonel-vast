Class {
	#name : 'TonelLoaderNamingStrategy',
	#superclass : 'TonelLoaderStrategy',
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelLoaderNamingStrategy >> nameForApp: aTonelLoaderApplication [

	self subclassResponsibility

]

{ #category : 'Not categorized' }
TonelLoaderNamingStrategy >> nameForSubApp: aTonelLoaderSubApplication [

	self subclassResponsibility

]
