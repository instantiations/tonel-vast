Extension {
	#name : 'Collection'
}

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Not categorized'] }
Collection >> tonelSingleEdgeTopologicallySortedCollection [
	"Replica from EtMonticelloImporter application to avoid unnecesary dependency."
	
	| unsorted sorted intermediate |
	
	"This is a simplification of the A.B Kahn topological sort algorithm
	 (Communications of the ACM5, 1962) that allows for only 1 incoming 
	 edge per node.  "
	
	unsorted := self asOrderedCollection.
	sorted := OrderedCollection new: unsorted size.
	intermediate := OrderedCollection new.

	"Begin with a list of all items that have no incoming edge (however that is defined)"
	intermediate := 
		(self reject: [:candidate | 
			self anySatisfy: [:item | (item = candidate) not and: [candidate tonelTopologicalSubordinateOf: item]]])
				 asOrderedCollection.
	"Remove the intermediate items from the unsorted list"
	unsorted removeAll: intermediate.
	
	"Short-circuit: if the unsorted collection is empty, there were no topological relationships,
	  so the collection is already topologically sorted. Return self."
	unsorted isEmpty ifTrue: [^self asOrderedCollection].
	
	"Until the intermediate list is empty..."
	[intermediate isEmpty]
		whileFalse: [ | superordinate |
			"remove the first item from the intermediate list and place it in the final list"
			superordinate := intermediate removeFirst.
			sorted add: superordinate.
			"add to the end of the intermediate list all items whose incoming 
			  edge originates at the removed item (while also removing those 
			  items from the unsorted list)"
			intermediate addAll: (
				unsorted removeAll: (
					unsorted select: [:ea | ea tonelTopologicalSubordinateOf: superordinate])).
			"Short-circuit: if the unsorted collection is empty, all of the remaining
			  items in intermediate are sorted. Just add them to the sorted final list"
			unsorted isEmpty 
				ifTrue: [
					sorted addAll: intermediate.
					intermediate := OrderedCollection new: 0]].
	
	"The resulting list guarantees that no item will precede the node from which its
	   edge originated, though the order of the non-dependent items is not guaranteed"
	^sorted
]
