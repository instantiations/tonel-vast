Class {
	#name : 'TonelWriterSubApplicationDefinition',
	#superclass : 'TonelWriterApplicationDefinition',
	#instVars : [
		'packageTag'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterSubApplicationDefinition >> computePackageTag [

	^application tonelPackageTag
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterSubApplicationDefinition >> computeTonelPackageName [

	^application rootApplication tonelPackageName
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterSubApplicationDefinition >> createClassDefinitionFor: class definedIn: anApplication [

	^(super createClassDefinitionFor: class definedIn: anApplication)
		tag: self packageTag;
		yourself
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterSubApplicationDefinition >> initializeFor: aSubApplication [

	super initializeFor: aSubApplication.
]

{ #category : 'accessing' }
TonelWriterSubApplicationDefinition >> packageTag [
	^packageTag ifNil: [packageTag := self computePackageTag]
]

{ #category : 'accessing' }
TonelWriterSubApplicationDefinition >> packageTag: anObject [
	packageTag := anObject
]
