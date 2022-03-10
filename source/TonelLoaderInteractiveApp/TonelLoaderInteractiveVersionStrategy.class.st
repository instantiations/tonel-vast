Class {
	#name : 'TonelLoaderInteractiveVersionStrategy',
	#superclass : 'TonelLoaderVersionStrategy',
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderInteractiveApp'
}

{ #category : 'Not categorized' }
TonelLoaderInteractiveVersionStrategy class >> description [

	^'Prompt for each Application'
]

{ #category : 'resolving' }
TonelLoaderInteractiveVersionStrategy >> versionFor: aTonelApplication [
	"Answer the version for anAppOrSubapp, 
	 prompting the user to specify one using an interactive dialog."

	^(System prompt: TonelMsg11 answer: String new) "$NLS$ Enter the version name to be used for imported classes and applications" ifNil: [''] "$NON-NLS$"
]
