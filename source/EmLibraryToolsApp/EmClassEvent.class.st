Class {
	#name : 'EmClassEvent',
	#superclass : 'EmEvent',
	#instVars : [
		'className',
		'applicationName',
		'ownerIsApp'
	],
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmClassEvent class >> className: aSymbol type: typeSymbol in: appOrSub [

	^(self identifier: aSymbol timeStamp: (appOrSub editionRecord entryAt: aSymbol) timeStamp)
		ownerIsApp: appOrSub isApplication;
		yourself
]

{ #category : 'accessing' }
EmClassEvent >> application [

	^Smalltalk classAt: self applicationName
]

{ #category : 'accessing' }
EmClassEvent >> applicationName [
	
	^applicationName
]

{ #category : 'accessing' }
EmClassEvent >> applicationName: aSymbol [

	
	applicationName := aSymbol
]

{ #category : 'accessing' }
EmClassEvent >> className [
	^className
]

{ #category : 'accessing' }
EmClassEvent >> className: anObject [
	className := anObject
]

{ #category : 'testing' }
EmClassEvent >> isClassEvent [

	^true
]

{ #category : 'accessing' }
EmClassEvent >> ownerIsApp [
	^ownerIsApp
]

{ #category : 'accessing' }
EmClassEvent >> ownerIsApp: anObject [
	ownerIsApp := anObject
]
