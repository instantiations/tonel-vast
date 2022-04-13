"

DESCRIPTION:
An instance of the EmTonelConfigurationMap class provides an object 
that represents a reference to an ENVY Library Configuration Map.

RESPONSIBILITY:
- Load the proper EmConfigurationMap from the ENVY Library
"
Class {
	#name : 'TonelEmConfigurationMapReference',
	#superclass : 'TonelConfigurationMap',
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelEmConfigurationMapReference class >> name: aString ts: seconds versionName: versionString [

	^(self new)
		name: aString;
		timeStamp: (EmTimeStamp new: seconds);
		versionName: versionString;
		yourself
]

{ #category : 'testing' }
TonelEmConfigurationMapReference >> isReference [
	"Answer whether receiver represents a reference to an actual EmConfigurationMap.
	 Receiver is a representation of a reference, so always return true."
	
	^true
]

{ #category : 'loading' }
TonelEmConfigurationMapReference >> loadWithRequiredMaps: aBoolean [
	"Load the receiver. And all its required maps first if aBoolean is true.
	Loading a required map may in turn load other required maps."

	| emConfigMap |
	aBoolean ifFalse: [^self].
	emConfigMap := (EmConfigurationMap editionsFor: self name)
		detect: [:one | self hasSameVersionAs: one]
		ifNone: [
			TonelLoaderError signal: (
				'Could not find configuration map <1p> <2p>'
					expandMacrosWith: self name
					with: self versionName)].
	emConfigMap isLoaded ifFalse: [
		emConfigMap loadWithRequiredMaps
	].
]
