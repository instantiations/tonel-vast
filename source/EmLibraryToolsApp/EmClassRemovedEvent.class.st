Class {
	#name : 'EmClassRemovedEvent',
	#superclass : 'EmClassEvent',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmClassRemovedEvent >> addToMonitor: anEmMonitor [

	(anEmMonitor lastEventForClass: self identifier) ifNil: 
			[self timeStamp isNil 
				ifTrue: 
					[(anEmMonitor lastTimeStampOfClass: self identifier in: self applicationName) 
						ifNotNil: 
							[:ts | 
							self setTimeStamp: ts.
							anEmMonitor addEvent: self]]
				ifFalse: [anEmMonitor basicAddEvent: self]]
		ifNotNil: 
			[:pastEvent | 
			pastEvent class = self class ifTrue: [self updateFrom: pastEvent in: anEmMonitor].
			anEmMonitor basicAddEvent: self]
]

{ #category : 'Not categorized' }
EmClassRemovedEvent >> revertOperation: aBoolean [

	^EmPluggableOperation
		for: self
		action: [:ev |
			EmImageBuilder loadClasses:
				(Array with: (ev application classEditionNamed: ev identifier at: ev timeStamp))]
]

{ #category : 'Not categorized' }
EmClassRemovedEvent >> updateFrom: anEmClassCreatedEvent in: anEmMonitor [

	self setTimeStamp: anEmClassCreatedEvent timeStamp.
	self ownerIsApp: anEmClassCreatedEvent ownerIsApp
]
