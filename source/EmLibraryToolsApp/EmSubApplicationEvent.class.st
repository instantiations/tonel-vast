Class {
	#name : 'EmSubApplicationEvent',
	#superclass : 'EmEvent',
	#instVars : [
		'parentIdentifier',
		'parentIsApp'
	],
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmSubApplicationEvent class >> for: appOrSub [

	^self identifier: appOrSub timeStamp: appOrSub timeStamp
]

{ #category : 'Not categorized' }
EmSubApplicationEvent >> addToMonitor: anEmMonitor [

	super addToMonitor: anEmMonitor
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
EmSubApplicationEvent >> initialize [

	parentIsApp := false
]

{ #category : 'testing' }
EmSubApplicationEvent >> isApplicationEvent [

	 ^true
]

{ #category : 'accessing' }
EmSubApplicationEvent >> parentIdentifier [
	^parentIdentifier
]

{ #category : 'accessing' }
EmSubApplicationEvent >> parentIdentifier: anObject [
	parentIdentifier := anObject
]

{ #category : 'accessing' }
EmSubApplicationEvent >> parentIsApp [
	^parentIsApp
]

{ #category : 'accessing' }
EmSubApplicationEvent >> parentIsApp: anObject [
	parentIsApp := anObject
]
