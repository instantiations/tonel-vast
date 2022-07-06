Extension {
	#name : 'TonelLoader'
}

{ #category : 'strategies-convenience' }
TonelLoader >> beInteractive [
	self useInteractivePrerequisitesSelection.
	self useInteractiveBaseEditionSelection.
	self useInteractiveVersioning
]

{ #category : 'strategies-convenience' }
TonelLoader >> useInteractiveBaseEditionSelection [
	self 
		baseEditionStrategy: (TonelLoaderInteractiveBaseEditionStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> useInteractivePrerequisitesSelection [
	self 
		prerequisitesStrategy: (TonelLoaderInteractivePrereqStrategy for: self)
]

{ #category : 'strategies-convenience' }
TonelLoader >> useInteractiveVersioning [
	self versionStrategy: (TonelLoaderInteractiveVersionStrategy for: self)
]
