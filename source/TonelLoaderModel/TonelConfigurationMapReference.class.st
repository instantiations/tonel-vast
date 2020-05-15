Class {
	#name : 'TonelConfigurationMapReference',
	#superclass : 'Object',
	#instVars : [
		'name',
		'versionName',
		'timeStamp'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelConfigurationMapReference class >> from: aDictionary [

	^self basicNew
		initializeFrom: aDictionary;
		yourself
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelConfigurationMapReference >> initializeFrom: aDictionary [

	name := aDictionary at: #name.
	timeStamp := EmTimeStamp new: (aDictionary at: #ts ifAbsent: [0]).
	versionName := aDictionary at: #versionName ifAbsent: [String new]
]

{ #category : 'accessing' }
TonelConfigurationMapReference >> name [
	^name
]

{ #category : 'accessing' }
TonelConfigurationMapReference >> name: anObject [
	name := anObject
]

{ #category : 'accessing' }
TonelConfigurationMapReference >> timeStamp [
	^timeStamp
]

{ #category : 'accessing' }
TonelConfigurationMapReference >> timeStamp: anObject [
	timeStamp := anObject
]

{ #category : 'accessing' }
TonelConfigurationMapReference >> versionName [
	^versionName
]

{ #category : 'accessing' }
TonelConfigurationMapReference >> versionName: anObject [
	versionName := anObject
]
