Class {
	#name : 'EmMethodEvent',
	#superclass : 'EmEvent',
	#instVars : [
		'className',
		'applicationName',
		'instanceLevel'
	],
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmMethodEvent class >> identifier: aSymbol timeStamp: anEmTimeStamp className: className applicationName: appName [

	^(self identifier: aSymbol timeStamp: anEmTimeStamp)
		className: className;
		applicationName: appName;
		yourself
]

{ #category : 'accessing' }
EmMethodEvent >> applicationName [
	^applicationName
]

{ #category : 'accessing' }
EmMethodEvent >> applicationName: anObject [
	applicationName := anObject
]

{ #category : 'accessing' }
EmMethodEvent >> className [
	^className
]

{ #category : 'accessing' }
EmMethodEvent >> className: anObject [
	className := anObject
]

{ #category : 'accessing' }
EmMethodEvent >> initialize [

	super initialize.
	instanceLevel := true
]

{ #category : 'accessing' }
EmMethodEvent >> instanceLevel [
	^instanceLevel
]

{ #category : 'accessing' }
EmMethodEvent >> instanceLevel: anObject [
	instanceLevel := anObject
]
