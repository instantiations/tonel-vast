Class {
	#name : 'EmApplicationsOperation',
	#superclass : 'EmEventsOperation',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'operations' }
EmApplicationsOperation >> mergeWith: anotherOperation [

	anotherOperation events do: [:anEvent | self events add: anEvent]
]

{ #category : 'testing' }
EmApplicationsOperation >> mustBeMergedWith: anEmEventOperation [

	^anEmEventOperation class = self class
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
EmApplicationsOperation >> setEvent: anEmEvent [

	super setEvent: anEmEvent.
	events add: anEmEvent
]
