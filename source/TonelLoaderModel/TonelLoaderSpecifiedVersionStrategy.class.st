Class {
	#name : 'TonelLoaderSpecifiedVersionStrategy',
	#superclass : 'TonelLoaderVersionStrategy',
	#instVars : [
		'versionName'
	],
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'accessing' }
TonelLoaderSpecifiedVersionStrategy >> versionFor: aTonelLoaderApplication [

	^self versionName
]

{ #category : 'accessing' }
TonelLoaderSpecifiedVersionStrategy >> versionName [
	^versionName
]

{ #category : 'accessing' }
TonelLoaderSpecifiedVersionStrategy >> versionName: anObject [
	versionName := anObject
]
