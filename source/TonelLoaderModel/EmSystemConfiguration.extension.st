Extension {
	#name : 'EmSystemConfiguration'
}

{ #category : 'EM-Internal' }
EmSystemConfiguration >> defaultApplication: anApplication during: aBlock [

	| previousDefault |
	previousDefault := self defaultApplication.
	[self defaultApplication: anApplication.
	aBlock value] ensure: [self defaultApplication: previousDefault]
]
