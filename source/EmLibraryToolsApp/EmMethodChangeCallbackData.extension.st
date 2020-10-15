Extension {
	#name : 'EmMethodChangeCallbackData'
}

{ #category : '*EmLibraryToolsApp',
 #vaCategories : ['EM-Internal'] }
EmMethodChangeCallbackData >> asEmEvent [

	| class methodTs |
	class := (Smalltalk classAt: self className).
	self instanceLevel ifFalse: [class := class class].
	
	self changeType = EMCAdded
		ifTrue: [ 
			methodTs  := (class methodDictionary at: self selector) timeStamp.
			^((EmMethodCreatedEvent identifier: self selector timeStamp: methodTs
							className: self className applicationName: self applicationName)
								instanceLevel: self instanceLevel)].
	self changeType = EMCRemoved
		ifTrue: [
			methodTs  := EmTimeStamp undefined.
			^((EmMethodRemovedEvent identifier: self selector timeStamp: methodTs
							className: self className applicationName: self applicationName)
								instanceLevel: self instanceLevel).
		].
	self changeType = EMCChanged
		ifTrue: [
			methodTs  := (class methodDictionary at: self selector) timeStamp.
			^((EmMethodChangedEvent identifier: self selector timeStamp: methodTs
							className: self className applicationName: self applicationName)
								instanceLevel: self instanceLevel).
		].
]
