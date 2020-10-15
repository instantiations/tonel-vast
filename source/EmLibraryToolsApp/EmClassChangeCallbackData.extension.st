Extension {
	#name : 'EmClassChangeCallbackData'
}

{ #category : '*EmLibraryToolsApp',
 #vaCategories : ['EM-Internal'] }
EmClassChangeCallbackData >> asEmEvent [

	(self changeType bitAnd: EMCAdded) == EMCAdded
		ifTrue: [| class |
			class := (Smalltalk classAt: className).
			^(class inheritsFrom: SubApplication)
				ifTrue: [| appOrSub |
					appOrSub := (Smalltalk classAt: className).
					class isApplication
						ifTrue: [
							EmApplicationCreatedEvent
								identifier: className
								timeStamp: appOrSub timeStamp]
						ifFalse: [
							(EmSubApplicationCreatedEvent
								identifier: className
								timeStamp: appOrSub timeStamp)
									parentIdentifier: appOrSub parent name;
									yourself]]
				ifFalse: [
					((EmClassCreatedEvent
						identifier: className
						timeStamp: (class timeStampIn: (Smalltalk classAt: applicationName)))
							applicationName: applicationName)]].
	(self changeType bitAnd: EMCRemoved) == EMCRemoved
		ifTrue: [
			^(self className == self applicationName)
				ifTrue: [
					EmApplicationUnloadedEvent
						identifier: self className
						timeStamp: EmTimeStamp undefined]
				ifFalse: [
					((EmClassRemovedEvent identifier: self className timeStamp: EmTimeStamp undefined)
						applicationName: self applicationName)]].

	(self changeType bitAnd: EMCChanged) == EMCChanged
		ifTrue: [

			"^((EmClassChangedEvent identifier: self selector timeStamp: methodTs
							className: self className applicationName: self applicationName)
								instanceLevel: self instanceLevel)."
			].
	^nil
]
