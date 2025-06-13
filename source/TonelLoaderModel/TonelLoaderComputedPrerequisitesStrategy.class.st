Class {
	#name : 'TonelLoaderComputedPrerequisitesStrategy',
	#superclass : 'TonelLoaderApplicationPrereqStrategy',
	#category : 'TonelLoaderModel'
}

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

	| subAppsPrerequisites |

	subAppsPrerequisites :=
		((tonelApplication subApplications collect: [:each | each prerequisites]) flattened asSet
			asOrderedCollection)
				copyWithout: Kernel.
	^tonelApplication prerequisites , subAppsPrerequisites
]
