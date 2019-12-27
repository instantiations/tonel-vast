Class {
	#name : 'TonelLoaderManualVersionStrategy',
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
TonelLoaderManualVersionStrategy >> versionFor: aTonelLoaderApplication [

	^self versionName
]

{ #category : 'accessing' }
TonelLoaderManualVersionStrategy >> versionName [
	^versionName
]

{ #category : 'accessing' }
TonelLoaderManualVersionStrategy >> versionName: anObject [
	versionName := anObject
]
