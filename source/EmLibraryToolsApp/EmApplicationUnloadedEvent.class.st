Class {
	#name : 'EmApplicationUnloadedEvent',
	#superclass : 'EmSubApplicationUnloadedEvent',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmApplicationUnloadedEvent >> revertOperation: aBoolean [

	^EmApplicationsLoadOperation for: self
]

{ #category : 'operations',
  #vaVisibility : 'private' }
EmApplicationUnloadedEvent >> updateTimeStampFrom: anEmEvent in: anEmMonitor [

	| newTimeStamp |
	newTimeStamp :=
		anEmEvent timeStamp isUndefined
			ifTrue: [anEmMonitor 
						lastTimeStampOfApplication: self identifier]
			ifFalse: [anEmEvent timeStamp].
	self setTimeStamp: newTimeStamp
]
