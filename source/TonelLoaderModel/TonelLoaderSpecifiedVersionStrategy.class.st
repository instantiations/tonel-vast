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

{ #category : 'Not categorized' }
TonelLoaderSpecifiedVersionStrategy class >> description [

	^'Specify one version for all loaded components'
]

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
