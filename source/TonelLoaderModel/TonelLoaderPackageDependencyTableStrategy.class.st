Class {
	#name : 'TonelLoaderPackageDependencyTableStrategy',
	#superclass : 'TonelLoaderPackageDependencyStrategy',
	#instVars : [
		'table'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'accessing-table' }
TonelLoaderPackageDependencyTableStrategy >> at: packageName [

	^self table at: packageName ifAbsentPut: [OrderedCollection new]
]

{ #category : 'accessing-table' }
TonelLoaderPackageDependencyTableStrategy >> at: packageName add: dependedPackageName [

	^(self at: packageName) add: dependedPackageName
]

{ #category : 'accessing-table' }
TonelLoaderPackageDependencyTableStrategy >> at: packageName put: aCollection [

	^self table at: packageName put: aCollection
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderPackageDependencyTableStrategy >> initialize [

	super initialize.
	table := Dictionary new
]

{ #category : 'api' }
TonelLoaderPackageDependencyTableStrategy >> prerequisitesFor: aTonelApplication [
	"Answer a collection of TonelApplications that are the prerequistes of aTonelApplication
	 based on a table between a package name and its collection of package prerequisites.
	 
	 E.g. 'Grease-Core-Tests' -> #('Grease-Core')."

	^self filterPrerequisites: (
		(self at: aTonelApplication packageName)
			collect: [:packageName | self loader applicationForPackageNamed: packageName])
]

{ #category : 'accessing' }
TonelLoaderPackageDependencyTableStrategy >> table [

	^table
]

{ #category : 'accessing' }
TonelLoaderPackageDependencyTableStrategy >> table: aDictionary [

	table := aDictionary
]
