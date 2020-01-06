Class {
	#name : 'TonelLoaderNoVersionStrategy',
	#superclass : 'TonelLoaderSpecifiedVersionStrategy',
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelLoaderNoVersionStrategy class >> description [

	^'Do not version, leave everything as open editions'
]

{ #category : 'Not categorized' }
TonelLoaderNoVersionStrategy >> versionFor: aTonelLoaderApplication [
	"Always returns nil as the version, so all applications and subapplications will remain open editions."

	^nil
]
