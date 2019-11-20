Extension {
	#name : 'Association'
}

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Not categorized'] }
Association >> tonelTopologicalSubordinateOf: anAssociation [
	"This method will return true if the current Association's key
	  is a topological subordinate of anAssociation's key"

	^self key tonelTopologicalSubordinateOf: anAssociation key
]
