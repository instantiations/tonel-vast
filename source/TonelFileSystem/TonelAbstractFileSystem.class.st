Class {
	#name : 'TonelAbstractFileSystem',
	#superclass : 'Object',
	#category : 'TonelFileSystem'
}

{
	#category : 'Not categorized'
}
TonelAbstractFileSystem >> createAppendStreamOn: aFilePath [

	^self subclassResponsibility
]

{
	#category : 'Not categorized'
}
TonelAbstractFileSystem >> createAppendStreamOn: filePath during: aOneArgBlock [

	| appendStream |

	appendStream := self createAppendStreamOn: filePath.
	^[aOneArgBlock value: appendStream] ensure: [appendStream close]
]

{
	#category : 'Not categorized'
}
TonelAbstractFileSystem >> createReadStreamOn: aFilePath [

	^self subclassResponsibility
]

{
	#category : 'Not categorized'
}
TonelAbstractFileSystem >> createReadStreamOn: aFilePath do: aBlock [
	| stream |
	stream := self createReadStreamOn: aFilePath.
	^[aBlock value: stream] ensure: [stream close]
]

{
	#category : 'Not categorized'
}
TonelAbstractFileSystem >> createWriteStreamOn: filePath during: aOneArgBlock [

	| appendStream |

	appendStream := self createWriteStreamOn: filePath.
	^[aOneArgBlock value: appendStream] ensure: [appendStream close]
]

{
	#category : 'Not categorized'
}
TonelAbstractFileSystem >> recursivelyRemoveWithAllFiles: aFilePath [

	^self subclassResponsibility
]
