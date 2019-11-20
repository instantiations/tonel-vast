Class {
	#name : 'TonelLoaderTest',
	#superclass : 'TonelBaseTest',
	#instVars : [
		'loader'
	],
	#category : 'TonelLoaderTests'
}

{ #category : 'Initialization' }
TonelLoaderTest >> setUp [
	super setUp.
	self writer: (TonelWriter on: self fileSystem).
	self reader: (TonelReader on: self fileSystem).
	self 
		writeThenReadProjectIncluding: (Array with: self tonelWriterTestAppName
				with: 'TonelWriterModel')
		from: self directoryForTestingPath.
	loader := TonelLoader on: reader
]

{ #category : 'Tests' }
TonelLoaderTest >> testApplicationHierarchy [

	| rootApp |

	self assert: loader applications size equals: 2.
	rootApp := (loader applicationNamed: self tonelWriterTestAppName).
	self assert: rootApp subApplications size equals: 1.
	
]

{ #category : 'Tests' }
TonelLoaderTest >> testConditions [

	| rootApp subApp |
	rootApp := (loader applicationNamed: self tonelWriterTestAppName).
	self assert: rootApp subApplications size equals: 1.
	subApp := rootApp subApplications first.
	self assert: subApp conditions size equals: 2.
	
	
]

{ #category : 'Initialization' }
TonelLoaderTest >> tonelWriterTestAppName [
	^'TonelWriterTests'
]

{ #category : 'Tests - Support' }
TonelLoaderTest >> writeThenReadProjectIncluding: applicationNames from: aRootDirPath [

	self writer
		writeProjectIncluding: (applicationNames collect: [:each | Smalltalk at: each asSymbol])
		sourceDirectoryNamed: 'source'
		into: aRootDirPath.
	self reader readPackages: applicationNames fromSourceDir: (aRootDirPath append: 'source')
]
