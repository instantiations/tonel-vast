Extension {
	#name : 'CfsPath'
}

{ #category : 'CFS-API' }
CfsPath >> readUtf8StreamDo: aBlock [
	"Opens a read stream on the receiver.  If a stream
	cannot be opened then answer nil. If it can,
	then evaluates @aBlock passing the stream as argument. 
	It also makes sure the stream is closed upon #aBlock termination.
	Answers the return of @aBlock execution"

	| stream latin1 |
  ^(stream := CfsReadFileStream open: self asString) isCfsError
		  ifFalse: [
				[ | utf8 converter |
					  converter := EsAbstractCodePageConverter current.
					  utf8 := stream contents.
					  latin1 := converter
							  convert: utf8
							  fromCodePage: converter class utf8CodePage
							  toCodePage: converter currentCodePage
							  bufferSize: utf8 size.
				] ensure: [stream close].
				latin1 ifNotNil: [aBlock value: latin1 readStream]]
]

{ #category : 'CFS-API' }
CfsPath >> utf8Contents [
	"Answer the contents of receiver asuming it was encoded using UTF-8."

	| output |

	output := WriteStream on: String new.
	self readUtf8StreamDo: [:input | [input atEnd] whileFalse: [output nextPut: input next]].
	^output contents
]
