Class {
	#name : 'TonelArtifactWriter',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'directory',
		'lineDelimiter'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Not categorized' }
TonelArtifactWriter class >> on: aFileSystem directory: aPath lineDelimiter: aLineDelimiter [
 
	^self new
		fileSystem: aFileSystem;
		directory: aPath;
		lineDelimiter: aLineDelimiter;
		yourself
]

{ #category : 'accessing' }
TonelArtifactWriter >> directory [
	^directory
]

{ #category : 'accessing' }
TonelArtifactWriter >> directory: anObject [
	directory := anObject
]

{ #category : 'Writing' }
TonelArtifactWriter >> ensureDirectory [
	self directory exists ifFalse: [self directory realize]
]

{ #category : 'Utility' }
TonelArtifactWriter >> filePathFor: anObject [

	^self directory append: anObject fileName
]

{ #category : 'accessing' }
TonelArtifactWriter >> fileSystem [
	^fileSystem
]

{ #category : 'accessing' }
TonelArtifactWriter >> fileSystem: anObject [
	fileSystem := anObject
]

{ #category : 'accessing' }
TonelArtifactWriter >> lineDelimiter [
	^lineDelimiter
]

{ #category : 'accessing' }
TonelArtifactWriter >> lineDelimiter: anObject [
	lineDelimiter := anObject
]

{ #category : 'accessing' }
TonelArtifactWriter >> tonelTypeName [
	self subclassResponsibility
]

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelArtifactWriter >> toSTONStringPretty: anObject [

	^String streamContents: 
			[:stream | 
			(STONWriter on: stream) 
				newLine: lineDelimiter;
				prettyPrint: true;
				nextPut: anObject]
]

{ #category : 'Utility' }
TonelArtifactWriter >> withStreamOn: aFilePath do: aBlock [

	fileSystem
		createWriteStreamOn: aFilePath
		during: [:writeStream | aBlock value: (TonelUTF8StreamWriterWrapper wrapping: writeStream)]
]

{ #category : 'accessing' }
TonelArtifactWriter >> write: anObject [

	self subclassResponsibility
]

{ #category : 'Writing' }
TonelArtifactWriter >> write: aBlock betweenCurlyBracesOn: aWriteStream [

	aWriteStream
		nextPutAll: self tonelTypeName;
		space;
		nextPutAll: '{';
		nextPutAll: lineDelimiter.
	aBlock value: aWriteStream.
	aWriteStream
		nextPutAll: lineDelimiter;
		nextPutAll: '}';
		nextPutAll: lineDelimiter
]
