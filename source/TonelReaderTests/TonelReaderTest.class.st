Class {
	#name : 'TonelReaderTest',
	#superclass : 'TonelBaseTest',
	#category : 'TonelReaderTests'
}

{ #category : 'Initialization' }
TonelReaderTest >> setUp [

	super setUp.
	self writer: (TonelWriter on: self fileSystem).
	self reader: (TonelReader on: self fileSystem)
]

{ #category : 'Tests' }
TonelReaderTest >> testWriteProject [

	self
		writeThenReadProjectIncluding: (Array with: 'TonelWriterTests' with: 'TonelWriterModel')
		from: self directoryForTestingPath
]

{ #category : 'Tests - Support' }
TonelReaderTest >> writeThenReadProjectIncluding: applicationNames from: aRootDirPath [

	self writer 
		applications: (applicationNames collect: [:each | Smalltalk at: each asSymbol]);
		writeProjectInto: aRootDirPath sourceDirectoryName: 'source'.
	self reader readPackages: applicationNames
		fromSourceDir: (aRootDirPath append: 'source')
]
