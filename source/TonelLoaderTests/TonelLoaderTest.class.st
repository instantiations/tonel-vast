Class {
	#name : 'TonelLoaderTest',
	#superclass : 'TonelBaseTest',
	#instVars : [
		'loader',
		'previousSuffix',
		'monitor'
	],
	#classInstVars : [
		'testRepositoriesPath'
	],
	#category : 'TonelLoaderTests'
}

{ #category : 'Not categorized' }
TonelLoaderTest class >> testRepositoriesPath [

	^testRepositoriesPath ifNil: [CfsPath defaultPath]
]

{ #category : 'Not categorized' }
TonelLoaderTest class >> testRepositoriesPath: aCfsPath [
	"Sets the base directory where the repositories used for tests are located."
	
	"self testRepositoriesPath: ((CfsPath named: CfsDirectoryDescriptor getcwd) append: '..\tonel-repos\tonel-vast\tests')"

	testRepositoriesPath := aCfsPath
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderTest >> deleteDirectoryInTearDown [

	^false
]

{ #category : 'Tests - Support',
  #vaVisibility : 'private' }
TonelLoaderTest >> directoryForTestingPath [

	^ (self class testRepositoriesPath append: self class name)
]

{ #category : 'Tests' }
TonelLoaderTest >> sampleApplicationName [
	^'TonelLoaderTestApplication'
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderTest >> setUp [
	super setUp.
	loader := TonelLoader readFromPath: self directoryForTestingPath.
	loader namingStrategy appSuffix: String new.
	monitor := EmLibrarySnapshot take
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelLoaderTest >> tearDown [

	super tearDown.
	monitor restore: true
]

{ #category : 'Tests' }
TonelLoaderTest >> testApplicationHierarchy [
	| testApp |
	self assert: loader applications size equals: 2.
	testApp := loader applicationNamed: self sampleApplicationName.
	self assert: testApp subApplications size equals: 1
]

{ #category : 'Tests' }
TonelLoaderTest >> testConditions [

	| rootApp subApp |
	rootApp := (loader applicationNamed: self sampleApplicationName).
	self assert: rootApp subApplications size equals: 1.
	subApp := rootApp subApplications first.
	self assert: subApp conditions isEmpty.
	
	
]

{ #category : 'Tests' }
TonelLoaderTest >> testLoadApplications [

	loader useSpecifiedVersion: AbtTimestamp now printString.
	loader loadAllApplications
]
