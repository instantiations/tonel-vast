Extension {
	#name : 'EmLibrary'
}

{ #category : '*EmLibraryToolsApp',
 #vaCategories : ['Not categorized'] }
EmLibrary >> operationsInterface: anEmLibraryAccesor [
	"Answer the interface used to perform library operations."

	libraryAccessor := anEmLibraryAccesor
]

{ #category : '*EmLibraryToolsApp',
 #vaCategories : ['EM-Internal'] }
EmLibrary >> resetOperationsInterface [

	libraryAccessor := nil
]
