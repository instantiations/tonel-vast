Class {
	#name : 'TonelReaderModel',
	#superclass : 'Application',
	#category : 'TonelReaderModel'
}

{ #category : 'loading/removing' }
TonelReaderModel class >> failedRemove [

	self loaded
]

{ #category : 'loading/removing' }
TonelReaderModel class >> loaded [
	"Send #initializeOnLoad to every class defined in this subapplication that implements it."

	defined do: [ :aClass |
		(aClass class includesSelector: #initializeOnLoad) ifTrue: [ aClass initializeOnLoad ] ]
]

{ #category : 'loading/removing' }
TonelReaderModel class >> removing [
	"Send #unload to every class defined in this subapplication that implements it."

	defined do: [ :aClass |
		(aClass class includesSelector: #unload) ifTrue: [ aClass unload ] ]
]
