"
I resolve configuration Maps by means of matching the timestamp (exact) or just the version name (loose).
"
Class {
	#name : 'TonelLoaderConfigMapResolverByVersion',
	#superclass : 'TonelLoaderConfigMapResolver',
	#instVars : [
		'matchVersionName'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'configuring' }
TonelLoaderConfigMapResolverByVersion >> beExact [
	"Sets receiver to match only configuration maps with the same timestamp."
	
	self matchVersionName: false
]

{ #category : 'configuring' }
TonelLoaderConfigMapResolverByVersion >> beLoose [
	"Sets receiver to match configuration maps by version name, regardless of its timestamp."
	
	self matchVersionName: true
]

{ #category : 'lookup' }
TonelLoaderConfigMapResolverByVersion >> configurationMapNamed: aString ts: anEmTimeStamp versionName: versionName ifNone: aBlock [
	"Looks into the Configuration Maps of receiver's loader for a configuration map
	 that matches name, timestamp or version name, evaluate aBlock if there is none."

	^self loader configurationMaps
		detect: [:one |
			one name = aString and: [
				one timeStamp = anEmTimeStamp or: [
					self matchVersionName ifTrue: [one versionName = versionName] ifFalse: [false]]]]
		ifNone: aBlock
]

{ #category : 'configuring' }
TonelLoaderConfigMapResolverByVersion >> matchVersionName [
	"Answer whether receiver matches by versionName if no timestamp is found."

	^matchVersionName ifNil: [matchVersionName := true]
]

{ #category : 'configuring' }
TonelLoaderConfigMapResolverByVersion >> matchVersionName: aBoolean [
	"Set whether receiver matches by versionName if no timestamp is found."

	matchVersionName := aBoolean
]

{ #category : 'lookup' }
TonelLoaderConfigMapResolverByVersion >> reference: aTonelEmConfigurationMapReference match: anEmConfigurationMap [
	"Answer whether aTonelEmConfigurationMapReference match anEmConfigurationMap
	 based on the timeStamp of the arguments."

	^aTonelEmConfigurationMapReference timeStamp = anEmConfigurationMap timeStamp or: [
		self matchVersionName
			ifTrue: [aTonelEmConfigurationMapReference versionName = anEmConfigurationMap versionName]
			ifFalse: [false]]
]
