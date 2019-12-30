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

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderVersionStrategy >> initialize [

	super initialize.
	alwaysCreateEditions := false
]

{ #category : 'Not categorized' }
TonelLoaderVersionStrategy >> versionFor: aTonelApplication [

	self subclassResponsibility
]
