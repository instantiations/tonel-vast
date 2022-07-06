Extension {
	#name : 'TonelReader'
}

{ #category : 'Convenience' }
TonelReader >> createLoader [
	
	^TonelLoader on: self
]
