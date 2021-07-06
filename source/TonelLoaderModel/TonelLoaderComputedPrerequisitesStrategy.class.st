Class {
	#name : 'TonelLoaderComputedPrerequisitesStrategy',
	#superclass : 'TonelLoaderApplicationPrereqStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'lookup' }
TonelLoaderComputedPrerequisitesStrategy >> concretePrerequisitesOf: aTonelApplication [

 
	^aTonelApplication prerequisiteApps reject: [ :eachApp |
		aTonelApplication prerequisiteApps anySatisfy: [ :checkApp |
			(eachApp = checkApp) not and: [
				checkApp withAllPrerequisites includes: eachApp ] ] ]
]

{ #category : 'lookup' }
TonelLoaderComputedPrerequisitesStrategy >> prerequisitesFor: tonelApplication current: aCollection [

	^tonelApplication prerequisites
]
