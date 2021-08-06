Class {
	#name : 'TonelArtifactWriter',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'directory',
		'lineDelimiter',
		'parent'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'instance-creation' }
TonelArtifactWriter class >> on: aFileSystem directory: aPath lineDelimiter: aLineDelimiter in: aTonelWriter [

	^(self new)
		fileSystem: aFileSystem;
		directory: aPath;
		lineDelimiter: aLineDelimiter;
		parent: aTonelWriter;
		yourself
]

{ #category : 'utility',
  #vaVisibility : 'private' }
TonelArtifactWriter >> convertIdentifier: className [

	^self parent convertIdentifier: className
]

{ #category : 'testing' }
TonelArtifactWriter >> convertsSharedPools [

	^self parent convertsSharedPools
]

{ #category : 'accessing' }
TonelArtifactWriter >> directory [
	^directory
]

{ #category : 'accessing' }
TonelArtifactWriter >> directory: anObject [
	directory := anObject
]

{ #category : 'writing' }
TonelArtifactWriter >> ensureDirectory [
	self directory exists ifFalse: [self directory realize]
]

{ #category : 'utility' }
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
TonelArtifactWriter >> parent [
	"Answer the TonelWriter parent of receiver."

	^parent
]

{ #category : 'accessing' }
TonelArtifactWriter >> parent: anObject [
	parent := anObject
]

{ #category : 'accessing' }
TonelArtifactWriter >> tonelTypeName [
	self subclassResponsibility
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelArtifactWriter >> toSTONStringPretty: anObject [

	^String streamContents: 
			[:stream | 
			(STONWriter on: stream) 
				newLine: lineDelimiter;
				prettyPrint: true;
				nextPut: anObject]
]

{ #category : 'utility' }
TonelArtifactWriter >> withStreamOn: aFilePath do: aBlock [

	fileSystem
		createWriteStreamOn: aFilePath
		during: [:writeStream | aBlock value: (TonelUTF8StreamWriterWrapper wrapping: writeStream)]
]

{ #category : 'accessing' }
TonelArtifactWriter >> write: anObject [

	self subclassResponsibility
]

{ #category : 'writing' }
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
