Class {
	#name : 'TonelLoaderConfigMapResolver',
	#superclass : 'TonelLoaderStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'lookup' }
TonelLoaderConfigMapResolver >> configurationMapNamed: aString ts: anEmTimeStamp versionName: versionName ifNone: aBlock [
	"Looks into the Configuration Maps of receiver's loader for a configuration map
	 that matches name, timestamp and version name, evaluate aBlock if there is none."

	^self loader configurationMaps detect: [:one | one name = aString] ifNone: aBlock
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderConfigMapResolver >> editionsFor: aTonelEmConfigurationMapReference [
	"Return all the available editions of the config map referenced by the argument."

	^EmConfigurationMap editionsFor: aTonelEmConfigurationMapReference name
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelLoaderConfigMapResolver >> reference: aTonelEmConfigurationMapReference match: anEmConfigurationMap [
	"Answer true whether aTonelEmConfigurationMapReference match anEmConfigurationMap
	 based on receiver matching criteria."
	
	self subclassResponsibility
	
]

{ #category : 'lookup' }
TonelLoaderConfigMapResolver >> resolveReference: aTonelEmConfigurationMapReference [
	^(self editionsFor: aTonelEmConfigurationMapReference) 
		detect: [:emConfigMap | self reference: aTonelEmConfigurationMapReference match: emConfigMap]
		ifNone: 
			[TonelLoaderError signal: ('Could not find configuration map <1p> <2p>' 
						expandMacrosWith: aTonelEmConfigurationMapReference name
						with: aTonelEmConfigurationMapReference versionName)]
]
