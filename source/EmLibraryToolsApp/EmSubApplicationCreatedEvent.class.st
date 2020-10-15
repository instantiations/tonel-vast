Class {
	#name : 'EmSubApplicationCreatedEvent',
	#superclass : 'EmSubApplicationEvent',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmSubApplicationCreatedEvent >> addToMonitor: anEmMonitor [

	(anEmMonitor lastEventForClass: self identifier) ifNotNil: [:event |
		anEmMonitor removeEvent: event
	].
	self basicAddToMonitor: anEmMonitor
]

{ #category : 'Not categorized' }
EmSubApplicationCreatedEvent >> parent [
	^Smalltalk classAt: self parentIdentifier
]

{ #category : 'Not categorized' }
EmSubApplicationCreatedEvent >> revertOperation: aBoolean [
	"Applies the neccesary changes in order to rever the event defined by receiver.
	 If aBoolean is true, also purges the changes from the Library (if applicable)."


	^EmPluggableOperation
		for: self
		action: [| subApp |
			subApp := Smalltalk classAt: self identifier.
			EmInterface current deleteSubApplication: subApp from: subApp parent in: 'true'.
			aBoolean
				ifTrue: [
					subApp partsRecordClass purge: self identifier at: self timeStamp.
					EmLibraryCache current flushEntriesForSubApplicationNamed: self identifier]]
]
