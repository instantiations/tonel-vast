Class {
	#name : 'EmSubApplicationUnloadedEvent',
	#superclass : 'EmSubApplicationEvent',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmSubApplicationUnloadedEvent >> addToMonitor: anEmMonitor [

	(anEmMonitor lastEventForClass: self identifier type: EmApplicationCreatedEvent)
		ifNil: [
			self timeStamp isUndefined
				ifTrue: [| lastTs |
					lastTs := (anEmMonitor
						lastTimeStampOfApplication: self identifier
						type: EmApplicationCreatedEvent).
					lastTs isUndefined
						ifFalse: [
							self setTimeStamp: lastTs.
							anEmMonitor addEvent: self]]
				ifFalse: [anEmMonitor basicAddEvent: self]]
		ifNotNil: [:pastEvent |
			pastEvent class = self class ifTrue: [self updateFrom: pastEvent in: anEmMonitor].
			anEmMonitor basicAddEvent: self]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
EmSubApplicationUnloadedEvent >> updateFrom: anEmEvent in: anEmMonitor [

	self updateTimeStampFrom: anEmEvent in: nil
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
EmSubApplicationUnloadedEvent >> updateTimeStampFrom: anEmEvent in: anEmMonitor [

	self setTimeStamp: anEmEvent timeStamp
]
