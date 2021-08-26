Class {
	#name : 'TonelLoaderSubapplicationsTagMappingStrategy',
	#superclass : 'TonelLoaderSubapplicationsMappingStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelLoaderSubapplicationsTagMappingStrategy >> createSubApplicationOf: aTonelLoaderApplication named: aSymbol [

	^(TonelLoaderSubApplication 
		on: (TonelReaderPackageDefinition name: aSymbol)
		in: self loader)
		rootTonelApplication: aTonelLoaderApplication;
		name: (self subApplicationNameForTag: aSymbol in: aTonelLoaderApplication);
		yourself
]

{ #category : 'api' }
TonelLoaderSubapplicationsTagMappingStrategy >> createSubApplicationsFor: tonelApplication in: emApp withRoot: emRootApp [

	tonelApplication subApplications do: [:tonelSubApp | | createSubApp |
		createSubApp := self loader alwaysCreateEditions.
		createSubApp
			ifFalse: [
				(emApp subApplications
					detect: [:one | one name = tonelSubApp identifier]
					ifNone: [nil])
						ifNil: [createSubApp := true]
						ifNotNil: [:emSubApp |
							createSubApp := (tonelSubApp hasChangesFor: emSubApp inRootApp: emRootApp)]].

		createSubApp
			ifTrue: [| emSubApplication |
				emSubApplication :=
					tonelSubApp createFor: emApp underCondition: 'true' withRoot: emRootApp.
				tonelApplication createDescriptionFor: emSubApplication]]
]

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelLoaderSubapplicationsTagMappingStrategy >> moveClass: tonelClass from: tonelApplication to: subApplication [

	tonelApplication packageDefinition moveClass: tonelClass to: subApplication packageDefinition
]

{ #category : 'internal' }
TonelLoaderSubapplicationsTagMappingStrategy >> subApplicationNameForTag: aSymbol in: aTonelLoaderApplication [

	^(self loader namingStrategy appNameWithoutSuffix: aTonelLoaderApplication) , aSymbol asString
]

{ #category : 'api' }
TonelLoaderSubapplicationsTagMappingStrategy >> subApplicationsOf: tonelApplication withRoot: rootTonelApplication [

	| tagMap |

	tonelApplication conditions size > 1
		ifTrue: [self error: 'This strategy does not work for applications with subapplications'].
	tagMap := Dictionary new.
	tonelApplication tonelDefinedClasses do: [:class |
		(class packageTagIn: tonelApplication packageName) ifNotNil: [:tag | | subApplication |
			subApplication := (tagMap
				at: tag
				ifAbsentPut: [self createSubApplicationOf: tonelApplication named: tag asSymbol]).
			self moveClass: class from: tonelApplication to: subApplication]].

	^tagMap values asOrderedCollection
]
