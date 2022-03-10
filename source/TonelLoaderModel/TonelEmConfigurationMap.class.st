"

DESCRIPTION:
An instance of the EmTonelConfigurationMap class provides an object 
that represents a reference to an ENVY Library Configuration Map.

RESPONSIBILITY:
- Load the proper EmConfigurationMap from the ENVY Library
"
Class {
	#name : 'TonelEmConfigurationMap',
	#superclass : 'TonelConfigurationMap',
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelEmConfigurationMap class >> name: aString ts: seconds versionName: versionString [

	^(self new)
		name: aString;
		timeStamp: (EmTimeStamp new: seconds);
		versionName: versionString;
		yourself
]

{ #category : 'loading' }
TonelEmConfigurationMap >> loadWithRequiredMaps: aBoolean [
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
	emConfigMap loadWithRequiredMaps.
]
