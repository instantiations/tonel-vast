Class {
	#name : 'EmMonitorOperation',
	#superclass : 'Object',
	#instVars : [
		'event'
	],
	#pools : [
		'EmConstants'
	],
	#category : 'EmLibraryToolsApp'
}

{ #category : 'instance-creation' }
EmMonitorOperation class >> for: anEmEvent [

	^self new
		setEvent: anEmEvent;
		yourself
]

{ #category : 'instance-creation' }
EmMonitorOperation class >> new [
	"Answer a new initialized instance of receiver."
	
	^super new initialize
]

{ #category : 'accessing' }
EmMonitorOperation >> event [

	^event
]

{ #category : 'operations' }
EmMonitorOperation >> executeFor: anEmChangelog [
	self executeFor: anEmChangelog purge: false
	
]

{ #category : 'operations' }
EmMonitorOperation >> executeFor: anEmChangelog purge: aBoolean [
	"Executes the receiver, aBoolean controls whether the Library entry should be purged afterwards."
]

{ #category : 'testing' }
EmMonitorOperation >> mustBeMergedWith: anEmEventOperation [

	^false
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
EmMonitorOperation >> setEvent: anEmEvent [

	event := anEmEvent
]
