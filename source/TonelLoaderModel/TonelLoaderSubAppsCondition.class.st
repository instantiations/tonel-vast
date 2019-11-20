Class {
	#name : 'TonelLoaderSubAppsCondition',
	#superclass : 'Object',
	#instVars : [
		'condition',
		'subApps'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelLoaderSubAppsCondition class >> condition: conditionCode subApps: aCollection [

	^self new
		setCondition: conditionCode subApps: aCollection;
		yourself
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderSubAppsCondition >> setCondition: conditionCode subApps: aCollection [

	condition := conditionCode.
	subApps := aCollection
]
