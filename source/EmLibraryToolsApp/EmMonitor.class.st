Class {
	#name : 'EmMonitor',
	#superclass : 'Object',
	#instVars : [
		'snapshot',
		'events',
		'logging',
		'handledEventsClasses'
	],
	#classVars : [
		'Default'
	],
	#pools : [
		'EmConstants'
	],
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmMonitor class >> default [

	^Default ifNil: [Default := self new initialize]
]

{ #category : 'logging' }
EmMonitor >> addEvent: anEmEvent [

	(self handledEventsClasses includes: anEmEvent class) ifFalse: [^self].
	(self events isEmpty or: [anEmEvent ~= self events last]) ifTrue: [anEmEvent addToMonitor: self]
]

{ #category : 'logging' }
EmMonitor >> basicAddEvent: anEmEvent [

	
	self events add: anEmEvent
	
]

{ #category : 'callbacks',
  #vaVisibility : 'private' }
EmMonitor >> classChanged: aMethod clientData: anObject callData: callData [

	callData asEmEvent ifNotNil: [:event | self addEvent: event ]
	
]

{ #category : 'initializing' }
EmMonitor >> defaultHandledEventsClasses [
	^EmSubApplicationEvent withAllSubclasses
]

{ #category : 'operations' }
EmMonitor >> disableDuring: aBlock [

	| previousLogging |

	previousLogging := logging.
	[
		self removeCallbacks.
		logging := false.
		aBlock value]
			ensure: [
				previousLogging
					ifTrue: [
						self initializeCallbacks.
						logging := previousLogging]]
]

{ #category : 'accessing' }
EmMonitor >> events [

	^events
]

{ #category : 'prerequisites',
  #vaVisibility : 'private' }
EmMonitor >> findAllApplicationsToLoadWith: aCollection [

	"Private - Find all prerequisites of the applications which are not loaded and ask
	 the user if they should be loaded also. If not answer nil.
	 
	 NOTE: This is a modified version of EtBrowser's version, that delegates on receiver to use its own strategy.
	 "

	| browser required applicationNames stream prereqNames toLoad cursorPosition prereq others |
	browser := EtBrowser new.
	required := browser managerInterface 
				allUnloadedPrerequisitesFor: aCollection.
	required isEmpty ifTrue: [^aCollection].
	aCollection size = 1 
		ifTrue: [applicationNames := aCollection first name]
		ifFalse: 
			[stream := WriteStream on: (browser stringClass new: 100).
			(aCollection asSortedCollection: Class sortBlock) do: 
					[:app | 
					stream
						cr;
						nextPutAll: '      ' , app name].	"$NON-NLS$"
			applicationNames := stream contents].
	stream := WriteStream on: (browser stringClass new: 100).
	required keys asSortedCollection do: 
			[:appName | 
			stream
				cr;
				nextPutAll: '      ' , appName].	"$NON-NLS$"
	prereqNames := stream contents.
	toLoad := aCollection asOrderedCollection.
	cursorPosition := System cursorPosition.
	required associationsDo: 
			[:assoc | 
			(toLoad detect: [:app | app symbol = assoc key] ifNone: []) isNil 
				ifTrue: 
					[assoc value isEmpty 
						ifTrue: 
							[| application |
							application := assoc key.
							^self signalMissingPrerequisiteOf: application].	"$NLS$ The prerequisite %1 does not exist in the library."
					assoc value size = 1 
						ifTrue: [prereq := assoc value first]
						ifFalse: 
							[| application prereqs |
							application := assoc key.
							prereqs := assoc value.
							prereq := self 
										selectPrerequisiteEditionOf: application
										in: prereqs
										using: browser
										at: cursorPosition].
					prereq isNil ifTrue: [^nil].
					others := self findAllApplicationsToLoadWith: (Array with: prereq).
					others isNil ifTrue: [^nil].
					toLoad addAll: others]].
	^toLoad
]

{ #category : 'configuring' }
EmMonitor >> handleApplicationEventsOnly [

	handledEventsClasses := EmSubApplicationEvent withAllSubclasses
]

{ #category : 'accessing' }
EmMonitor >> handledEventsClasses [

	^handledEventsClasses
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
EmMonitor >> initialize [
	super initialize.
	logging := false.
	handledEventsClasses := self defaultHandledEventsClasses
]

{ #category : 'callbacks',
  #vaVisibility : 'private' }
EmMonitor >> initializeCallbacks [

	System callbackInterface 
		addCallback: EmNmethodChangedCallback
		receiver: self 
		selector: #methodChanged:clientData:callData:
		clientData: nil.
	
	System callbackInterface 
		addCallback: EmNclassChangedCallback
		receiver: self 
		selector: #classChanged:clientData:callData:
		clientData: nil.
	
		
]

{ #category : 'operations' }
EmMonitor >> installLoggingAccessor [
	EmLoggingAccessor install
]

{ #category : 'testing' }
EmMonitor >> isLogging [

	^logging
]

{ #category : 'lookup' }
EmMonitor >> lastEventForClass: aSymbol [

	
	self events reverseDo: [:each | 
		each identifier = aSymbol ifTrue: [^each]
	].
	^nil
]

{ #category : 'lookup' }
EmMonitor >> lastEventForClass: aSymbol type: anEmEventClass [

	self events reverseDo: [:each |
		(each identifier = aSymbol and: [each class = anEmEventClass]) ifTrue: [^each]].
	^nil
]

{ #category : 'lookup' }
EmMonitor >> lastTimeStampOfApplication: appName [

	^(self lastEventForClass: appName)
		ifNil: [self snapshot timeStampAt: appName in: appName]
		ifNotNil: [:event | event timeStamp]
]

{ #category : 'lookup' }
EmMonitor >> lastTimeStampOfApplication: appName type: anEmEventClass [

	^(self lastEventForClass: appName type: anEmEventClass)
		ifNil: [self snapshot timeStampForApplication: appName]
		ifNotNil: [:event | event timeStamp]
]

{ #category : 'lookup' }
EmMonitor >> lastTimeStampOfClass: className in: appName [

	^(self lastEventForClass: className)
		ifNil: [self snapshot timeStampAt: appName in: appName]
		ifNotNil: [:event | event timeStamp]
]

{ #category : 'callbacks',
  #vaVisibility : 'private' }
EmMonitor >> methodChanged: source clientData: anObject callData: callData [

	"callData asEmEvent ifNotNil: [:event | self log: event ]"
	
]

{ #category : 'printing' }
EmMonitor >> printOn: aStream [
	
	super printOn: aStream.
	aStream nextPut: $[.
	aStream 
		nextPutAll: self events size printString.
	aStream nextPut: $]
	
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
EmMonitor >> release [

	super release.
	self removeCallbacks
]

{ #category : 'callbacks' }
EmMonitor >> removeCallbacks [

	System callbackInterface 
	removeCallback: EmNmethodChangedCallback
	receiver: self
	selector: #methodChanged:clientData:callData:
	clientData: nil.
	
	System callbackInterface 
		removeCallback: EmNclassChangedCallback
		receiver: self 
		selector: #classChanged:clientData:callData:
		clientData: nil.
	
		
]

{ #category : 'logging' }
EmMonitor >> removeEvent: anEmEvent [

	
	self events remove: anEmEvent
]

{ #category : 'operations' }
EmMonitor >> resetEvents [
	
	events := OrderedCollection new
]

{ #category : 'operations' }
EmMonitor >> restart [
	"Another way to call a start."
	
	self start.
]

{ #category : 'lookup' }
EmMonitor >> reverseDetect: aBlock ifNone: notFoundBlock [
	
	self events reverseDo: [:each |
		(aBlock value: each) ifTrue: [^each]
	].
	^notFoundBlock value
]

{ #category : 'operations' }
EmMonitor >> rollback [

	self rollback: false
]

{ #category : 'operations' }
EmMonitor >> rollback: aBoolean [
	"Reverts the events of receiver.
	 If aBoolean is true, also purge editions from library (when applicable)."

	self disableDuring: [self rollbackEvents: self events purge: aBoolean].
	self takeSnapshot
]

{ #category : 'operations',
  #vaVisibility : 'private' }
EmMonitor >> rollbackEvents: eventsToRevert purge: aBoolean [

	| nextOperation eventStream |

	eventStream := eventsToRevert copy reverse readStream.
	nextOperation := nil.
	[eventStream atEnd] whileFalse: [| event revertOperation |
		event := eventStream next.
		revertOperation := event revertOperation: false.
		nextOperation isNil
			ifTrue: [nextOperation := revertOperation]
			ifFalse: [
				(revertOperation mustBeMergedWith: nextOperation)
					ifTrue: [nextOperation := nextOperation mergeWith: revertOperation]
					ifFalse: [
						nextOperation executeFor: self.
						nextOperation := revertOperation]].
		(eventStream atEnd and: [nextOperation notNil]) ifTrue: [nextOperation executeFor: self].
		eventsToRevert remove: event]
]

{ #category : 'accessing' }
EmMonitor >> snapshot [

	^snapshot
]

{ #category : 'operations' }
EmMonitor >> start [
	self stop.
	events := OrderedCollection new.
	self takeSnapshot.
	self startLogging
]

{ #category : 'operations',
  #vaVisibility : 'private' }
EmMonitor >> startLogging [
	logging := true.
	self installLoggingAccessor.
	self initializeCallbacks
]

{ #category : 'operations' }
EmMonitor >> stop [
	self stopLogging
]

{ #category : 'operations',
  #vaVisibility : 'private' }
EmMonitor >> stopLogging [
	self removeCallbacks.
	EmLibrary default resetOperationsInterface.
	logging := false
]

{ #category : 'operations' }
EmMonitor >> takeSnapshot [
	snapshot := EmLibrarySnapshot take
]
