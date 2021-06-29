Class {
	#name : 'TonelLoaderPackagePrereqsStrategy',
	#superclass : 'TonelLoaderStrategy',
	#instVars : [
		'filter'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'accessing' }
TonelLoaderPackagePrereqsStrategy >> filter [
	
	^filter 
]

{ #category : 'accessing' }
TonelLoaderPackagePrereqsStrategy >> filter: aValuableBlock [

	filter := aValuableBlock
]

{ #category : 'filtering',
  #vaVisibility : 'private' }
TonelLoaderPackagePrereqsStrategy >> filterPrerequisites: aCollection [
	"Answer a collection of TonelApplications given that they fullfill the prerequisites filter 
	 or return aCollection as is if no filter was defined."

	^self filter
		ifNil: [aCollection]
		ifNotNil: [aCollection select: [:each | filter value: each]]
]
