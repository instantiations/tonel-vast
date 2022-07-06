Extension {
	#name : 'EmLibrary'
}

{ #category : 'Not categorized' }
EmLibrary >> operationsInterface: anEmLibraryAccesor [
	"Answer the interface used to perform library operations."

	libraryAccessor := anEmLibraryAccesor
]

{ #category : 'EM-Internal' }
EmLibrary >> resetOperationsInterface [

	libraryAccessor := nil
]
