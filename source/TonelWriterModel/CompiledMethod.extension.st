Extension {
	#name : 'CompiledMethod'
}

{ #category : 'Tonel-Internal',
  #vaVisibility : 'private' }
CompiledMethod >> tonelSourceString [
	"Return the source code for the receiver."

    "Bypassing CompiledMethod>>#sourceString that manipulates the source.
     https://vast-support.instantiations.com/support/tickets/80256
     https://github.com/instantiations/tonel-vast/issues/140"

    ^EmLibrary cache methodSourceAt: self filePointer decompress: true
]
