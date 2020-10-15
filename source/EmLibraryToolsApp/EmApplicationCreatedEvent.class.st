Class {
	#name : 'EmApplicationCreatedEvent',
	#superclass : 'EmSubApplicationCreatedEvent',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'accessing' }
EmApplicationCreatedEvent >> revertOperation: aBoolean [

	^EmApplicationsRemovalOperation for: self
]
