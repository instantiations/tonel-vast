Class {
	#name : 'TonelLoaderComputedPrerequisitesStrategy',
	#superclass : 'TonelLoaderApplicationPrereqStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderComputedPrerequisitesStrategy >> computeAddsMissingPrerequisites [
	"Determine whether we add missing prerequisites based on whether there was 
	 prerequisite metadata in the package definition of the loader applications.
	 
	 NOTE: This is so because if there is package prerequisite metadata it 
	 likely means the code was exported from VAST, and already defines what are
	 the prerequisites. If it doesn't have any metadata, it's likely that the packages 
	 come from another dialect, and we need to to compute the missing prerequisites."

	^self loader applications noneSatisfy: [:each | each packageDefinition hasPrerequisitesMetadata]


]

{ #category : 'lookup' }
TonelLoaderComputedPrerequisitesStrategy >> concretePrerequisitesOf: aTonelApplication [
	"Answer the immediate prerequisite application of aTonelApplication."

	^aTonelApplication prerequisiteApps reject: [:eachApp |
		aTonelApplication prerequisiteApps anySatisfy: [:checkApp |
			(eachApp = checkApp) not and: [checkApp withAllPrerequisites includes: eachApp]]]
]

{ #category : 'lookup' }
TonelLoaderComputedPrerequisitesStrategy >> prerequisitesFor: tonelApplication current: aCollection [
	"Answer a collection of EmShadowApplication that are the prerequistes applications 
	 of aTonelApplication as they're specified in the tonelApplication, ignoring aCollection
	 of the current specified prerequisites.
	 
	 Answers:
		<EmShadowApplication>
	 "

	^tonelApplication prerequisites
]
