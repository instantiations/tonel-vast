Class {
	#name : 'TonelLoaderInteractivePrereqStrategy',
	#superclass : 'TonelLoaderApplicationPrereqStrategy',
	#category : 'TonelLoaderInteractiveApp'
}

{ #category : 'api' }
TonelLoaderInteractivePrereqStrategy >> concretePrerequisitesOf: aTonelApplication [
	"Answer the immediate prerequisite application of aTonelApplication,
	 by prompting the user to choose them."

	^self prerequisitesFor: aTonelApplication current: aTonelApplication prerequisiteApps
]

{ #category : 'api' }
TonelLoaderInteractivePrereqStrategy >> prerequisitesFor: tonelApplication current: aCollection [
	"Answer a collection of EmShadowApplication that are the prerequistes applications 
	 of aTonelApplication based on prompting the user with a dialog to choose them from.
	 
	 Answers:
		<EmShadowApplication>
	 "

	^EtPrerequisiteCollectingPrompter
		prompt: (
			'Please select the prequisites for %1 (chains will be resolved after selection)'
				bindWith: tonelApplication name)
		chooseFrom: (
			self loader systemLoadedApplications
				reject: [:anApp | tonelApplication allDependentApplications includes: anApp])
		current: aCollection
		alwaysRequired: (Set with: Kernel) "$NLS$ Please select the prequisites for %1 (chains will be resolved after selection)"
]
