Class {
	#name : 'TonelLoaderPackageTablePrereqsStrategy',
	#superclass : 'TonelLoaderPackagePrereqsStrategy',
	#instVars : [
		'table'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'accessing-table' }
TonelLoaderPackageTablePrereqsStrategy >> at: packageName [

	^self table at: packageName ifAbsentPut: [Set new]
]

{ #category : 'accessing-table' }
TonelLoaderPackageTablePrereqsStrategy >> at: packageName add: dependedPackageName [

	^(self at: packageName) add: dependedPackageName
]

{ #category : 'accessing-table' }
TonelLoaderPackageTablePrereqsStrategy >> at: packageName put: aCollection [

	^self at: packageName put: aCollection
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderPackageTablePrereqsStrategy >> initialize [

	super initialize.
	table := Dictionary new
]

{ #category : 'api' }
TonelLoaderPackageTablePrereqsStrategy >> prerequisitesFor: aTonelApplication [
	"Answer a collection of TonelApplications that are the prerequistes of aTonelApplication
	 based on a table between a package name and its collection of package prerequisites.
	 
	 E.g. 'Grease-Core-Tests' -> #('Grease-Core')."

	^self filterPrerequisites: (
		(self at: aTonelApplication packageName)
			collect: [:packageName | self loader applicationForPackageNamed: packageName])
]

{ #category : 'accessing' }
TonelLoaderPackageTablePrereqsStrategy >> table [

	^table
]

{ #category : 'accessing' }
TonelLoaderPackageTablePrereqsStrategy >> table: aDictionary [

	table := aDictionary
]
