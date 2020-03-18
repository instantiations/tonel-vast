Class {
	#name : 'TonelEmConfigurationMap',
	#superclass : 'TonelConfigurationMap',
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelEmConfigurationMap class >> name: aString versionName: versionString [



	^self new
		name: aString;
		versionName: versionString;
		yourself
	
]

{ #category : 'loading' }
TonelEmConfigurationMap >> loadWithRequiredMaps [

	| emConfigMap |
	emConfigMap := (EmConfigurationMap editionsFor: self name)
		detect: [:one | one versionName = self versionName]
		ifNone: [
			TonelLoaderError signal: (
				'Could not find configuration map <1p> <2p>'
					expandMacrosWith: self name
					with: self versionName)].
	emConfigMap loadWithRequiredMaps
]
