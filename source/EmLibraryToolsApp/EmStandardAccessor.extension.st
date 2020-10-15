Extension {
	#name : 'EmStandardAccessor'
}

{ #category : '*EmLibraryToolsApp',
 #vaCategories : ['EM-Internal'] }
EmStandardAccessor >> isLoggingAccessor [

	^false
]

{ #category : '*EmLibraryToolsApp',
 #vaCategories : ['initializing'] }
EmStandardAccessor >> monitor [

	^EmMonitor default
]
