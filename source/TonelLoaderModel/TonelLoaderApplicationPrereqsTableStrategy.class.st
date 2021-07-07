Class {
	#name : 'TonelLoaderApplicationPrereqsTableStrategy',
	#superclass : 'TonelLoaderApplicationPrereqStrategy',
	#instVars : [
		'table'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'api' }
TonelLoaderApplicationPrereqsTableStrategy >> addPrerequisite: emApplication to: tonelApplication [
	"Add emApplication as a prerequisite to tonelApplication.
	 NOTE: Since we base prerequisites on a table, we only won't add anything that is not in the table."
	
]

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

{ #category : 'api' }
TonelLoaderApplicationPrereqsTableStrategy >> concretePrerequisitesOf: aTonelApplication [

 
	^self prerequisitesFor: aTonelApplication current: aTonelApplication prerequisiteApps
]

{ #category : 'accessing-table',
  #vaVisibility : 'private' }
TonelLoaderApplicationPrereqsTableStrategy >> initialize [

	super initialize.
	table := Dictionary new
]

{ #category : 'api' }
TonelLoaderApplicationPrereqsTableStrategy >> prerequisitesFor: aTonelApplication current: aCollection [
	"Answer a collection of EmShadowApplication that are the prerequistes application of aTonelApplication together
	 with aCollection of Applications."

	^((self at: aTonelApplication packageName)
		collect: [:applicationName | self applicationNamed: applicationName]) , aCollection
]

{ #category : 'accessing' }
TonelLoaderApplicationPrereqsTableStrategy >> table [

	^table
]

{ #category : 'accessing' }
TonelLoaderApplicationPrereqsTableStrategy >> table: aDictionary [

	table := aDictionary
]
