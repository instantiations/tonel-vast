Extension {
	#name : 'Behavior'
}

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Tonel-Comparing'] }
Behavior >> tonelTopologicalSubordinateOf: aBehavior [
	"This method will returns true if the current Behavior 
	  is a subclass of aBehavior" 
	^self superclass = aBehavior
]
