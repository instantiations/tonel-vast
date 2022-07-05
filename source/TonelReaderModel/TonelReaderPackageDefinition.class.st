"
TonelReaderPackageDefinition is unit of declaration at which Tonel works.

In Tonel, everything is defined in the context of a Package.
In VAST we can have Applications, but also they can form limitless hierarchies of SubApplications.

Read more about how the mapping works at:
<https://github.com/instantiations/tonel-vast/blob/master/docs/strategies.md#package-tags-and-subapplications-strategy>
"
Class {
	#name : 'TonelReaderPackageDefinition',
	#superclass : 'TonelReaderDefinition',
	#instVars : [
		'classDefinitions',
		'extensions',
		'parent',
		'metadata'
	],
	#category : 'TonelReaderModel'
}

{ #category : 'constants' }
TonelReaderPackageDefinition class >> definitionType [

	^'Package'
]

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelReaderPackageDefinition >> addClassDefinition: aTonelReaderClassDefinition withAll: anArray [


	self classDefinitions at: aTonelReaderClassDefinition put: anArray
]

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelReaderPackageDefinition >> addExtension: aTonelReaderClassExtensionDefinition withAll: anArray [


	self extensions at: aTonelReaderClassExtensionDefinition put: anArray
	
]

{ #category : 'accessing' }
TonelReaderPackageDefinition >> appName [
	"Answer the app name of receiver."

	^self name copyWithout: $-
]

{ #category : 'accessing' }
TonelReaderPackageDefinition >> classDefinitions [
	"Answer aDictionary of the class definitions of receiver, 
	 containing the TonelReaderClassDefinition its keys and their methods
	 as values."

	^classDefinitions ifNil: [classDefinitions := Dictionary new]
]

{ #category : 'accessing' }
TonelReaderPackageDefinition >> definedClasses [
	"Answer the defined classes of receiver."

	^self classDefinitions keys
]

{ #category : 'accessing' }
TonelReaderPackageDefinition >> extendedClasses [
	"Answer the collection of the classes extended by methods defined in the receiver."
	
	^self extensions keys copy
]

{ #category : 'accessing' }
TonelReaderPackageDefinition >> extensions [

	^extensions ifNil: [extensions := Dictionary new]
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelReaderPackageDefinition >> initializeFromMetadata: aDictionary [

	| dialectMetadata |

	super initializeFromMetadata: aDictionary.
	metadata := Dictionary new.

	"We use this to guard in the case there is a specific #metadata attribute in Tonel Spec."
	dialectMetadata := (aDictionary at: #metadata ifAbsent: [aDictionary]).

	#(vaParent vaSubApplications vaPrerequisites) do: [:key |
		dialectMetadata at: key ifPresent: [:value | metadata at: key put: value]]
		"conditions := aCollection collect: [:	aDict |
			TonelReaderSubAppsCondition condition: (aDict at: #condition) subApps: (aDict at: #subapps)
		]"

]

{ #category : 'accessing' }
TonelReaderPackageDefinition >> metadata [
	^metadata ifNil: [metadata := Dictionary new]
]

{ #category : 'operations' }
TonelReaderPackageDefinition >> moveClass: tonelClass to: otherPackageDefinition [
	"Moves a tonelClass <TonelReaderClassDefinition> defined in receiver
	 to be part of otherPackageDefinition."

	otherPackageDefinition classDefinitions at: tonelClass put: (self classDefinitions at: tonelClass).
	self classDefinitions removeKey: tonelClass
]

{ #category : 'accessing' }
TonelReaderPackageDefinition >> parent [
	"Answer the parent element of receiver.
	 Since Tonel doesn't support nested packages, we read that from VA specific metadata."

	^self metadata at: #vaParent ifAbsent: [nil]
]
