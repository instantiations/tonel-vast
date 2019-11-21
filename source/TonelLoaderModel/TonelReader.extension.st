Extension {
	#name : 'TonelReader'
}

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Convenience'] }
TonelReader >> createLoader [
	
	^TonelLoader on: self
]
