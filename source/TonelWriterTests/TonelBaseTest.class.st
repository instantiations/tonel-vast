Class {
	#name : 'TonelBaseTest',
	#superclass : 'TestCase',
	#instVars : [
		'writer',
		'fileSystem',
		'reader'
	],
	#category : 'TonelWriterTests'
}

{ #category : 'Not categorized' }
TonelBaseTest class >> isAbstract [
	^ self name = #TonelBaseTest
]

{ #category : 'Preconditions' }
TonelBaseTest >> assertContentsOfFileAt: aLocation equals: aString [

	self assert: (fileSystem contentsOfFileAt: self directoryForTestingString, aLocation) isEqualSkippingSeparatorsTo: aString
]

{ #category : 'Preconditions' }
TonelBaseTest >> assertFileSystemIncludesFileAt: aLocation [

	self assert: (self fileSystem includes: self directoryForTestingString,  aLocation)
]

{ #category : 'accessing' }
TonelBaseTest >> deleteDirectoryInTearDown [

	^true
]

{ #category : 'accessing' }
TonelBaseTest >> directoryForTestingPath [

	^ ((CfsPath named: '.') append: self class name)
]

{ #category : 'Initialization' }
TonelBaseTest >> directoryForTestingString [
	^ self directoryForTestingPath asString
]

{ #category : 'accessing' }
TonelBaseTest >> fileSystem [
	^fileSystem
]

{ #category : 'accessing' }
TonelBaseTest >> fileSystem: anObject [
	fileSystem := anObject
]

{ #category : 'accessing' }
TonelBaseTest >> reader [
	^reader
]

{ #category : 'accessing' }
TonelBaseTest >> reader: anObject [
	reader := anObject
]

{ #category : 'Initialization' }
TonelBaseTest >> setUp [

	super setUp.
	fileSystem := TonelCfsFileSystem new
]

{ #category : 'Initialization' }
TonelBaseTest >> tearDown [

	self deleteDirectoryInTearDown
		ifTrue: [
			self directoryForTestingPath exists
				ifTrue: [
					fileSystem recursivelyRemoveWithAllFiles: self directoryForTestingPath asString]]
]

{ #category : 'accessing' }
TonelBaseTest >> writer [
	^writer
]

{ #category : 'accessing' }
TonelBaseTest >> writer: anObject [
	writer := anObject
]
