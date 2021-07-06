Class {
	#name : 'TonelLoaderInteractivePrereqStrategy',
	#superclass : 'TonelLoaderApplicationPrereqStrategy',
	#category : 'TonelLoaderInteractiveApp'
}

{ #category : 'api' }
TonelLoaderInteractivePrereqStrategy >> concretePrerequisitesOf: aTonelApplication [

 
	^self prerequisitesFor: aTonelApplication current: aTonelApplication prerequisiteApps
]

{ #category : 'api' }
TonelLoaderInteractivePrereqStrategy >> prerequisitesFor: tonelApplication current: aCollection [

	^EtPrerequisiteCollectingPrompter 
		prompt: ('Please select the prequisites for %1 (chains will be resolved after selection)' 
				bindWith: tonelApplication name)
		chooseFrom: (self loader systemLoadedApplications 
				reject: [:anApp | tonelApplication allDependentApplications includes: anApp])
		current: aCollection
		alwaysRequired: (Set with: Kernel)	"$NLS$ Please select the prequisites for %1 (chains will be resolved after selection)"
]
