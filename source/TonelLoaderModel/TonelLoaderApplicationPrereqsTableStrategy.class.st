Class {
	#name : 'TonelLoaderApplicationPrereqsTableStrategy',
	#superclass : 'TonelLoaderApplicationPrereqStrategy',
	#instVars : [
		'table'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'api',
  #vaVisibility : 'private' }
TonelLoaderApplicationPrereqsTableStrategy >> applicationNamed: applicationName [

	^Smalltalk
		at: applicationName asSymbol
		ifAbsent: [
			Application shadowClass named: applicationName asSymbol timeStamp: EmTimeStamp undefined]
]

{ #category : 'accessing-table' }
TonelLoaderApplicationPrereqsTableStrategy >> at: packageName [

	^self table at: packageName ifAbsentPut: [OrderedCollection new]
]

{ #category : 'accessing-table' }
TonelLoaderApplicationPrereqsTableStrategy >> at: packageName put: aCollection [

	^self table at: packageName put: aCollection
]

{ #category : 'accessing-table',
  #vaVisibility : 'private' }
TonelLoaderApplicationPrereqsTableStrategy >> initialize [

	super initialize.
	table := Dictionary new
]

{ #category : 'api' }
TonelLoaderApplicationPrereqsTableStrategy >> prerequisitesFor: aTonelApplication current: aCollection [
	"Answer a collection of EmShadowApplication that are the prerequistes application of aTonelApplication.
	 E.g. 'Seaside-Core' -> #('GreaseCoreApp')."

	^(self at: aTonelApplication packageName) collect: [:applicationName |
		aCollection
			detect: [:one | one name = applicationName asSymbol]
			ifNone: [self applicationNamed: applicationName]]
]

{ #category : 'accessing' }
TonelLoaderApplicationPrereqsTableStrategy >> table [

	^table
]

{ #category : 'accessing' }
TonelLoaderApplicationPrereqsTableStrategy >> table: aDictionary [

	table := aDictionary
]
