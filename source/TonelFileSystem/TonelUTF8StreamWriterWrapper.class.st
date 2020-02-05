Class {
	#name : 'TonelUTF8StreamWriterWrapper',
	#superclass : 'Object',
	#instVars : [
		'writeStream'
	],
	#category : 'TonelFileSystem'
}

{ #category : 'Instance Creation' }
TonelUTF8StreamWriterWrapper class >> wrapping: aWriteStream [

	^self new initializeWrapping: aWriteStream
]

{ #category : 'Stream API' }
TonelUTF8StreamWriterWrapper >> << aString [

	self nextPutAll: aString
]

{ #category : 'Stream API' }
TonelUTF8StreamWriterWrapper >> contents [

	^writeStream contents
]

{ #category : 'Initialization' }
TonelUTF8StreamWriterWrapper >> initializeWrapping: aWriteStream [

	writeStream := aWriteStream
]

{ #category : 'Stream API' }
TonelUTF8StreamWriterWrapper >> nextPut: aCharacter [

	self nextPutAll: aCharacter asString
]

{ #category : 'Stream API' }
TonelUTF8StreamWriterWrapper >> nextPutAll: aString [

	| converter |

	converter := EsAbstractCodePageConverter current.
	writeStream nextPutAll: (
		converter
			convert: aString asString
			fromCodePage: converter currentCodePage
			toCodePage: converter class utf8CodePage)
]

{ #category : 'Stream API' }
TonelUTF8StreamWriterWrapper >> space [
	writeStream nextPut: Character space
]

{ #category : 'Stream API' }
TonelUTF8StreamWriterWrapper >> tab [
	writeStream nextPut: Character tab
]
