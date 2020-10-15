Class {
	#name : 'EmLoggingAccessor',
	#superclass : 'EmStandardAccessor',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmLoggingAccessor class >> install [

	^self installInto: EmLibrary default
]

{ #category : 'Not categorized' }
EmLoggingAccessor class >> installInto: anEmLibrary [

	^(self new)
		installInto: anEmLibrary;
		yourself
]

{ #category : 'Not categorized' }
EmLoggingAccessor class >> new [

	^self basicNew initialize
]

{ #category : 'logging' }
EmLoggingAccessor >> applicationAddInitialApplicationFor: appOrSub named: versionName [
		"Create the initial edition for appOrSub in the library."
	
	| event |
	super applicationAddInitialApplicationFor: appOrSub named: versionName.
	event := appOrSub isApplication
		ifTrue: [EmApplicationCreatedEvent identifier: appOrSub name timeStamp: appOrSub shadows first timeStamp]
		ifFalse: [
		 (EmSubApplicationCreatedEvent identifier: appOrSub name timeStamp: appOrSub shadows first timeStamp)
			parentIdentifier: appOrSub parent;
			yourself ].
	self notifyEvent: event.
]

{ #category : 'logging' }
EmLoggingAccessor >> applicationAddInitialClassFor: appOrSub class: aClass [
		"Create the initial edition for className to appOrSub in the library."
		
	super applicationAddInitialClassFor: appOrSub class: aClass.
	self notifyEvent: (EmClassCreatedEvent className: aClass name type: #defined in: appOrSub)
]

{ #category : 'logging' }
EmLoggingAccessor >> applicationAddPrerequisiteFor: appOrSub prereqName: aName toExpr: expr ifUnable: exit [
	
	
	super applicationAddPrerequisiteFor: appOrSub
	prereqName: aName
	toExpr: expr
	ifUnable: [
		exit value.
		^self].
	
	self notifyEvent: ((appOrSub isApplication 
				ifTrue: [EmApplicationPrerequisitesChangedEvent]
				ifFalse: [EmSubApplicationPrerequisitesChangedEvent])
					for: appOrSub expression: expr prereqName: aName)
]

{ #category : 'logging' }
EmLoggingAccessor >> applicationNewEditionFor: appOrSub ifUnable: exit [

		"Create a new edition for appOrSub in the library."

	
	super applicationNewEditionFor: appOrSub ifUnable: [exit value. ^self].
	self notifyEvent: (EmApplicationEditionCreatedEvent identifier: appOrSub name timeStamp: appOrSub timeStamp)
]

{ #category : 'operations' }
EmLoggingAccessor >> installInto: anEmLibrary [

	anEmLibrary operationsInterface == self ifFalse: [
		anEmLibrary operationsInterface: self
	]
]

{ #category : 'testing' }
EmLoggingAccessor >> isLoggingAccessor [

	^true
]

{ #category : 'logging' }
EmLoggingAccessor >> notifyEvent: anEmEvent [

	self monitor addEvent: anEmEvent
]

{ #category : 'operations' }
EmLoggingAccessor >> restore: anEmLibrary [

	anEmLibrary resetOperationsInterface
]
