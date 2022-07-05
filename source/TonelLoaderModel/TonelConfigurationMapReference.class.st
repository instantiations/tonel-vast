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
TonelConfigurationMapReference >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '[';
		nextPutAll: self name printString;
		space;
		nextPutAll: self versionName printString;
		space;
		nextPutAll: self timeStamp printString;
		nextPutAll: ']'
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
