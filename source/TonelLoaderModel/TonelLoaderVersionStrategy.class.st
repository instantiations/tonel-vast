Class {
	#name : 'TonelLoaderVersionStrategy',
	#superclass : 'TonelLoaderStrategy',
	#instVars : [
		'alwaysCreateEditions'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelLoaderVersionStrategy class >> description [

	| className |
	className := self name asString.
	^className copyFrom: 'TonelLoader' size + 1 to: className size - 'Strategy' size
]

{ #category : 'Not categorized' }
TonelLoaderVersionStrategy class >> isGit [

	^self name = #TonelLoaderGitVersionStrategy
]

{ #category : 'Not categorized' }
TonelLoaderVersionStrategy class >> isSpecific [

	^self name = #TonelLoaderSpecifiedVersionStrategy
]

{ #category : 'accessing' }
TonelLoaderVersionStrategy >> alwaysCreateEditions [
	^alwaysCreateEditions
]

{ #category : 'accessing' }
TonelLoaderVersionStrategy >> alwaysCreateEditions: aBoolean [
	alwaysCreateEditions := aBoolean
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderVersionStrategy >> initialize [

	super initialize.
	alwaysCreateEditions := false
]

{ #category : 'versioning' }
TonelLoaderVersionStrategy >> isSpecific [

	^self class isSpecific
]

{ #category : 'versioning' }
TonelLoaderVersionStrategy >> versionFor: aTonelApplication [

	self subclassResponsibility
]
