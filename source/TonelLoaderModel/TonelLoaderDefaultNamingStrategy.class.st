Class {
	#name : 'TonelLoaderDefaultNamingStrategy',
	#superclass : 'TonelLoaderNamingStrategy',
	#instVars : [
		'appSuffix',
		'subAppSuffix',
		'prefix',
		'mappings',
		'guessAppSuffix'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> appNameWithoutSuffix: aTonelLoaderApplication [

	| appName suffixToRemove |

	appName := aTonelLoaderApplication name.
	suffixToRemove := (self appSuffix isEmpty and: [self guessAppSuffix])
			ifTrue: [ 
				(appName endsWithSubCollection: 'App')
					ifTrue: ['App']
					ifFalse: [String new]
			]
			ifFalse: [
				self appSuffix
			].
	^suffixToRemove isEmpty
		ifTrue: [appName]
		ifFalse: [appName copyFrom: 1 to: appName size - suffixToRemove size]
]

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> appSuffix [
	^appSuffix
]

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> appSuffix: anObject [
	appSuffix := anObject
]

{ #category : 'Not categorized' }
TonelLoaderDefaultNamingStrategy >> guessAppSuffix [
	"Answer whether we will guess the app suffix when trying to know the base name of a parent app.
	 E.g. to guess MyApplication from MyApplicationApp."
	 
	^guessAppSuffix ifNil: [guessAppSuffix := false]
]

{ #category : 'accessing' }
TonelLoaderDefaultNamingStrategy >> guessAppSuffix: aBoolean [

	guessAppSuffix := aBoolean
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
