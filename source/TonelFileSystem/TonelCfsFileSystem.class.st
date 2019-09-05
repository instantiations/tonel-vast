Class {
	#name : 'TonelCfsFileSystem',
	#superclass : 'TonelAbstractFileSystem',
	#pools : [
		'CfsConstants'
	],
	#category : 'TonelFileSystem'
}

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> assertIsDirectory: aFilePath [

	(self isDirectory: aFilePath) ifTrue: [^self].
	self error: aFilePath , ' is not a directory'

]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> cfsPathFrom: aFilePath [

	^CfsPath named: aFilePath
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> contentsOfFileAt: aFilePath [

	^self createReadStreamOn: aFilePath during: [:readStream | readStream contents]
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> createAppendStreamOn: aFilePath [

	^self
		open: aFilePath
		withFlags: (OWRONLY bitOr: (OCREAT bitOr: OAPPEND))
		ifUnable: [:errorMessage |
			self error: (
				#'Could not open file "%1" due to error '
					bindWith: aFilePath
					with: errorMessage asString)]
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> createReadStreamOn: aFilePath [

	| stream |

	^(stream := CfsReadFileStream open: aFilePath) isCfsError
		ifTrue: [self error: 'Cannot open read file stream: ' , aFilePath]
		ifFalse: [stream]
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> createReadStreamOn: aFilePath during: aOneArgBlock [

	| readStream |

	readStream := self createReadStreamOn: aFilePath.
	^[aOneArgBlock value: readStream] ensure: [readStream close]
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> createWriteStreamOn: aFilePath [

	^self
		open: aFilePath
		withFlags: (CfsConstants::OWRONLY bitOr: (CfsConstants::OCREAT bitOr: CfsConstants::OTRUNC))
		ifUnable: [:errorMessage |
			self error: 'Cannot open write file stream: ' , aFilePath , ' error: ' , errorMessage]
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> fileNamesInDirectoryAt: aFilePath [

	^((self cfsPathFrom: aFilePath) filesMatching: '*')
		reject: [:filePathString | (CfsPath named: filePathString) isDirectory]
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> includes: aFilePath [

	^(self cfsPathFrom: aFilePath) exists
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> isDirectory: aFilePath [

	| directoryDescriptor filePathString |

	filePathString := aFilePath.

	^filePathString notEmpty and: [
		directoryDescriptor := CfsDirectoryDescriptor opendir: filePathString pattern: nil mode: CfsConstants::FREG.
		directoryDescriptor isCfsError ifTrue: [^false].
		directoryDescriptor closedir.
		true]
]

{
	#category : 'Not categorized',
	#vaVisibility : 'private'
}
TonelCfsFileSystem >> open: path withFlags: flags ifUnable: aOneArgBlock [

	| streamOrCfsError |

	streamOrCfsError := CfsFileStream open: path asString oflag: flags.

	^streamOrCfsError isCfsError
		ifTrue: [aOneArgBlock value: streamOrCfsError message]
		ifFalse: [streamOrCfsError]
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> pathnameFrom: aString [

	^aString asPath
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> recursivelyRemoveWithAllFiles: aFilePath [

	| result |

	(self subDirectoriesOf: aFilePath) do: [:subdir | self recursivelyRemoveWithAllFiles: subdir].
	result := (self cfsPathFrom: aFilePath) deleteAll.
	result isCfsError
		ifTrue: [
			self error:
				'Cannot recursively remove all files from: ' , aFilePath  , ' error: ' ,
					result message]
]

{
	#category : 'Not categorized'
}
TonelCfsFileSystem >> subDirectoriesOf: aFilePath [

	| path |

	self assertIsDirectory: aFilePath.
	path := self cfsPathFrom: aFilePath.
	^(self cfsPathFrom: aFilePath) directoryNames
		collect: [:subdirString | aFilePath , path class pathSeparator asString , subdirString]
]
