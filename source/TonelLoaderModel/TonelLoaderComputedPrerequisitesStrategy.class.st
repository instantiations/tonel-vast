Class {
	#name : 'TonelLoaderComputedPrerequisitesStrategy',
	#superclass : 'TonelLoaderPrereqStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'lookup' }
TonelLoaderComputedPrerequisitesStrategy >> prerequisitesFor: tonelApplication current: aCollection [

	^tonelApplication prerequisites
]

{ #category : 'lookup' }
TonelLoaderComputedPrerequisitesStrategy >> selectPrerequisitesEditionOfApplication: anApplication [

	
	| shadows |
	shadows := (Application shadowsFor: anApplication name).
	^shadows isEmpty ifFalse: [ shadows first]
	
]
