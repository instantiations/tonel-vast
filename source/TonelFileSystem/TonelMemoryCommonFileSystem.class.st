Class {
	#name : 'TonelMemoryCommonFileSystem',
	#superclass : 'TonelAbstractFileSystem',
	#instVars : [
		'files'
	],
	#category : 'TonelFileSystem'
}

{
	#category : 'Not categorized'
}
TonelMemoryCommonFileSystem class >> new [

	^super new initialize
]

{
	#category : 'Not categorized'
}
TonelMemoryCommonFileSystem >> contentsOfFileAt: aFilePath [

	^files at: aFilePath asString ifAbsent: [self error: 'Cannot open read file on: ' , aFilePath]
]

{
	#category : 'Not categorized'
}
TonelMemoryCommonFileSystem >> createAppendStreamOn: filePath during: aOneArgBlock [

	files at: filePath asString put: (String streamContents: aOneArgBlock)
]

{
	#category : 'Not categorized'
}
TonelMemoryCommonFileSystem >> createReadStreamOn: aFilePath [

	^ReadStream on: (self contentsOfFileAt: aFilePath)
]

{
	#category : 'Not categorized'
}
TonelMemoryCommonFileSystem >> files [

	^files
]

{
	#category : 'Not categorized'
}
TonelMemoryCommonFileSystem >> initialize [

	super initialize.
	files := Dictionary new
]
