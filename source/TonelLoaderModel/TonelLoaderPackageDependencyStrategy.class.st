Class {
	#name : 'TonelLoaderPackageDependencyStrategy',
	#superclass : 'TonelLoaderStrategy',
	#instVars : [
		'filter'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'accessing' }
TonelLoaderPackageDependencyStrategy >> filter [
	
	^filter 
]

{ #category : 'accessing' }
TonelLoaderPackageDependencyStrategy >> filter: aValuableBlock [

	filter := aValuableBlock
]

{ #category : 'filtering',
  #vaVisibility : 'private' }
TonelLoaderPackageDependencyStrategy >> filterPrerequisites: aCollection [
	"Answer a collection of TonelApplications given that they fullfill the prerequisites filter 
	 or return aCollection as is if no filter was defined."

	^self filter
		ifNil: [aCollection]
		ifNotNil: [aCollection select: [:each | filter value: each]]
]
