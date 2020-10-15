Class {
	#name : 'EmEventsOperation',
	#superclass : 'EmMonitorOperation',
	#instVars : [
		'events'
	],
	#category : 'EmLibraryToolsApp'
}

{ #category : 'accessing' }
EmEventsOperation >> add: anEmEvent [
	
	self events add: anEmEvent
]

{ #category : 'accessing' }
EmEventsOperation >> events [

	^events
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
EmEventsOperation >> initialize [

	super initialize.
	events := OrderedCollection new.
]
