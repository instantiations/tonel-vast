Class {
	#name : 'TonelLoaderSubapplicationsConditionsMappingStrategy',
	#superclass : 'TonelLoaderSubapplicationsMappingStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelLoaderSubapplicationsConditionsMappingStrategy >> createSubApplicationsFor: tonelApplication in: emAppOrSubapp withRoot: emRootApp [

	tonelApplication loadableConditions keysAndValuesDo: [:conditionCode :tonelSubApps |
		tonelSubApps do: [:tonelSubApp | | createSubApp |
			createSubApp := self loader alwaysCreateEditions.
			createSubApp
				ifFalse: [
					(emAppOrSubapp subApplications
						detect: [:one | one name = tonelSubApp identifier]
						ifNone: [nil])
							ifNil: [createSubApp := true]
							ifNotNil: [:emSubApp |
								createSubApp := (tonelSubApp
									hasChangesFor: emSubApp
									inRootApp: emRootApp)]].

			createSubApp
				ifTrue: [| emSubApplication |
					emSubApplication :=
						tonelSubApp
							createFor: emAppOrSubapp
							underCondition: conditionCode
							withRoot: emRootApp.
					tonelApplication createDescriptionFor: emSubApplication]]]
]

{ #category : 'Not categorized' }
TonelLoaderSubapplicationsConditionsMappingStrategy >> subApplicationsOf: tonelApplication withRoot: rootTonelApplication [

	| conditionsSubApps |

	conditionsSubApps := Set new.
	tonelApplication conditions keysAndValuesDo: [:conditionCode :subApps |
		(SubApplication isExpressionValid: conditionCode)
			ifTrue: [
				subApps do: [:each |
					conditionsSubApps add: each.
					each rootTonelApplication: tonelApplication rootTonelApplication]]
			ifFalse: [tonelApplication logIgnoredShadowSubapps: subApps]].
	^conditionsSubApps
]
