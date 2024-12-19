Extension {
	#name : 'CompiledMethod'
}

{ #category : 'Tonel-Internal',
  #vaVisibility : 'private' }
CompiledMethod >> tonelSourceString [
	"Return the source code for the receiver as is, without any source filtering."

	^EmLibrary cache methodSourceAt: self filePointer decompress: true
]
