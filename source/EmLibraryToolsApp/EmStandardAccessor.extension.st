Extension {
	#name : 'EmStandardAccessor'
}

{ #category : 'EM-Internal' }
EmStandardAccessor >> isLoggingAccessor [

	^false
]

{ #category : 'initializing' }
EmStandardAccessor >> monitor [

	^EmMonitor default
]
