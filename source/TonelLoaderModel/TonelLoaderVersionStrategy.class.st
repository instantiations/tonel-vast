Class {
	#name : 'TonelLoaderVersionStrategy',
	#superclass : 'TonelLoaderStrategy',
	#instVars : [
		'alwaysCreateEditions'
	],
	#category : 'TonelLoaderModel'
}

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
TonelLoaderVersionStrategy >> versionFor: aTonelApplication [

	self subclassResponsibility
]
