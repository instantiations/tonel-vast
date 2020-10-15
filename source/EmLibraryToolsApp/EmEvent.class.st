"
I represent a generic change event.

My subjectName is a way to hold a reference to the name of event, 
it might be the class name, the application name or the method name.
"
Class {
	#name : 'EmEvent',
	#superclass : 'Object',
	#instVars : [
		'identifier',
		'timeStamp',
		'previousTimeStamp'
	],
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmEvent class >> identifier: aSymbol timeStamp: anEmTimeStamp [

	^ self new
		setIdentifier: aSymbol;
		setTimeStamp: anEmTimeStamp;
		yourself

]

{ #category : 'comparing' }
EmEvent >> = anEmEvent [

	^self class = anEmEvent class and: 
		[self identifier = anEmEvent identifier 
			and: [self timeStamp = anEmEvent timeStamp]]
]

{ #category : 'operations' }
EmEvent >> addToMonitor: anEmMonitor [

	
	anEmMonitor basicAddEvent: self
	
]

{ #category : 'operations',
  #vaVisibility : 'private' }
EmEvent >> basicAddToMonitor: anEmMonitor [

	
	anEmMonitor basicAddEvent: self
	
]

{ #category : 'accessing' }
EmEvent >> hash [

	^(self class hash bitXor: self identifier hash) bitXor: self timeStamp
]

{ #category : 'accessing' }
EmEvent >> identifier [
	^identifier
]

{ #category : 'testing' }
EmEvent >> isApplicationEvent [

	^false
]

{ #category : 'testing' }
EmEvent >> isClassEvent [

	^false
]

{ #category : 'testing' }
EmEvent >> isMethodEvent [

	^false
]

{ #category : 'operations' }
EmEvent >> new [

	^super new initialize
]

{ #category : 'accessing' }
EmEvent >> previousTimeStamp [
	^previousTimeStamp
]

{ #category : 'accessing' }
EmEvent >> previousTimeStamp: anObject [
	previousTimeStamp := anObject
]

{ #category : 'printing' }
EmEvent >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(#';
		nextPutAll: self identifier;
		nextPutAll: ')'
]

{ #category : 'accessing' }
EmEvent >> revertOperation [

	^self revertOperation: true
]

{ #category : 'operations' }
EmEvent >> revertOperation: aBoolean [

	^EmNullOperation for: self
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
EmEvent >> setIdentifier: aSymbol [
	identifier := aSymbol
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
EmEvent >> setTimeStamp: anObject [
	timeStamp := anObject
]

{ #category : 'accessing' }
EmEvent >> timeStamp [
	^timeStamp
]
