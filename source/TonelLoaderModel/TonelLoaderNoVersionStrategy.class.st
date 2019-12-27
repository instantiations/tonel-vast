Class {
	#name : 'TonelLoaderNoVersionStrategy',
	#superclass : 'TonelLoaderManualVersionStrategy',
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelLoaderNoVersionStrategy >> versionFor: aTonelLoaderApplication [
	"Always returns nil as the version, so all applications and subapplications will remain open editions."

	^nil
]
