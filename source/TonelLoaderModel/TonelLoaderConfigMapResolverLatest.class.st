Class {
	#name : 'TonelLoaderConfigMapResolverLatest',
	#superclass : 'TonelLoaderConfigMapResolver',
	#instVars : [
		'versionedEditionsOnly'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderConfigMapResolverLatest >> editionsFor: aTonelEmConfigurationMapReference [
	"Return all the available editions of the config map referenced by the argument,
	 filtering each according to whether only versioned editions should be returned."

	| editions |

	editions := (EmConfigurationMap editionsFor: aTonelEmConfigurationMapReference name).
	^self versionedEditionsOnly
		ifTrue: [editions select: [:each | each isVersion]]
		ifFalse: [editions]
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderConfigMapResolverLatest >> reference: aTonelEmConfigurationMapReference match: anEmConfigurationMap [
	"Answer whether aTonelEmConfigurationMapReference match anEmConfigurationMap
	 based on the timeStamp of the arguments."

	^aTonelEmConfigurationMapReference name = anEmConfigurationMap name
]

{ #category : 'accessing' }
TonelLoaderConfigMapResolverLatest >> versionedEditionsOnly [
	"Answer whether receiver will match only versioned editions."

	^versionedEditionsOnly ifNil: [versionedEditionsOnly := true]
]

{ #category : 'accessing' }
TonelLoaderConfigMapResolverLatest >> versionedEditionsOnly: aBoolean [
	"Sets whether receiver will match only versioned editions."

	versionedEditionsOnly := aBoolean
]
