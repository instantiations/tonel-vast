Class {
	#name : 'TonelLoaderDefaultNamingStrategy',
	#superclass : 'TonelLoaderNamingStrategy',
	#instVars : [
		'appSuffix',
		'subAppSuffix',
		'prefix',
		'mappings'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> appSuffix [
	^appSuffix
]

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> appSuffix: anObject [
	appSuffix := anObject
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderDefaultNamingStrategy >> initialize [

	prefix := String new.
	appSuffix := String new.
	subAppSuffix := String new.
	mappings := Dictionary new
]

{ #category : 'mappings' }
TonelLoaderDefaultNamingStrategy >> mappingAt: aString ifAbsent: aBlock [
	
		^self mappings at: aString ifAbsent: aBlock
]

{ #category : 'mappings' }
TonelLoaderDefaultNamingStrategy >> mappingAt: aString put: anObject [
	
		^self mappings at: aString put: anObject
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderDefaultNamingStrategy >> mappings [
	^mappings
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderDefaultNamingStrategy >> mappings: anObject [
	mappings := anObject
]

{ #category : 'resolving' }
TonelLoaderDefaultNamingStrategy >> nameForApp: aTonelLoaderApplication [

	^self
		mappingAt: aTonelLoaderApplication packageName
		ifAbsent: [self prefix , aTonelLoaderApplication packageDefinition appName , self appSuffix]
]

{ #category : 'resolving' }
TonelLoaderDefaultNamingStrategy >> nameForSubApp: aTonelLoaderSubApplication [

	^self
		mappingAt: aTonelLoaderSubApplication packageName
		ifAbsent: [self prefix , aTonelLoaderSubApplication packageDefinition appName , self subAppSuffix]
]

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> prefix [

	^prefix
]

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> prefix: aString [
	prefix := aString
]

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> subAppSuffix [
	^subAppSuffix
]

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> subAppSuffix: anObject [
	subAppSuffix := anObject
]
