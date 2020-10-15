Class {
	#name : 'EmSubApplicationPrerequisitesChangedEvent',
	#superclass : 'EmSubApplicationEvent',
	#instVars : [
		'previousPrerequisites',
		'expression',
		'prereqName'
	],
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmSubApplicationPrerequisitesChangedEvent class >> for: anApplication [

	^(self identifier: anApplication name timeStamp: anApplication timeStamp)
	
]

{ #category : 'Not categorized' }
EmSubApplicationPrerequisitesChangedEvent class >> for: appOrSub expression: expr prereqName: aSymbol [

	^(self for: appOrSub) 
		setExpression: expr prereqName: aSymbol;
		yourself
	
]

{ #category : 'accessing' }
EmSubApplicationPrerequisitesChangedEvent >> expression [
	^expression
]

{ #category : 'accessing' }
EmSubApplicationPrerequisitesChangedEvent >> expression: anObject [
	expression := anObject
]

{ #category : 'accessing' }
EmSubApplicationPrerequisitesChangedEvent >> prereqName [
	^prereqName
]

{ #category : 'accessing' }
EmSubApplicationPrerequisitesChangedEvent >> prereqName: anObject [
	prereqName := anObject
]

{ #category : 'accessing' }
EmSubApplicationPrerequisitesChangedEvent >> previousPrerequisites [
	^previousPrerequisites
]

{ #category : 'accessing' }
EmSubApplicationPrerequisitesChangedEvent >> previousPrerequisites: anObject [
	previousPrerequisites := anObject
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
EmSubApplicationPrerequisitesChangedEvent >> setExpression: aString prereqName: aSymbol [

	expression := aString.
	prereqName := aSymbol
]
