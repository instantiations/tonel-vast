Class {
	#name : 'EmClassCreatedEvent',
	#superclass : 'EmClassEvent',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmClassCreatedEvent class >> identifier: aSymbol type: classType in: appOrSub [
	"Enter the new method definition below and click 'Resume'."
	
	^self identifier: aSymbol timeStamp: ((Smalltalk classAt: aSymbol) timeStampIn: appOrSub) 
]

{ #category : 'Not categorized' }
EmClassCreatedEvent >> addToMonitor: anEmMonitor [

	(anEmMonitor lastEventForClass: self identifier type: self class) 
		ifNil: [self basicAddToMonitor: anEmMonitor]
		ifNotNil: [:pastEvent | pastEvent updateFrom: self in: anEmMonitor]
]

{ #category : 'Not categorized' }
EmClassCreatedEvent >> revertOperation: aBoolean [
	"Applies the neccesary changes in order to rever the event defined by receiver.
	 We don't revert if the application is not an edition, because it would require marking the application as scratch."

	^EmPluggableOperation
		for: self
		action: [:ev |
			ev application ifNotNil: [:application |
				(application isEdition or: [application isScratch])
					ifTrue: [(Smalltalk classAt: ev identifier) deleteFrom: application]]]
]

{ #category : 'Not categorized' }
EmClassCreatedEvent >> updateFrom: anEmClassCreatedEvent in: anEmMonitor [

	self
		setTimeStamp: anEmClassCreatedEvent timeStamp;
		applicationName: anEmClassCreatedEvent applicationName.
	self ownerIsApp: (Smalltalk classAt: self applicationName) isApplication
]
