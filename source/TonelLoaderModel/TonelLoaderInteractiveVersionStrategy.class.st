Class {
	#name : 'TonelLoaderInteractiveVersionStrategy',
	#superclass : 'TonelLoaderVersionStrategy',
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelLoaderInteractiveVersionStrategy class >> description [

	^'Prompt for each Application'
]

{ #category : 'Not categorized' }
TonelLoaderInteractiveVersionStrategy >> versionFor: aTonelApplication [
	
	^(System prompt: TonelMsg11 answer: String new) "$NLS$ Enter the version name to be used for imported classes and applications" ifNil: [''] "$NON-NLS$"
]
