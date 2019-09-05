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

{
	#category : 'constants'
}
TonelReaderPackageDefinition class >> definitionType [

	^'Package'
]

{
	#category : 'operations',
	#vaVisibility : 'private'
}
TonelReaderPackageDefinition >> addClassDefinition: aTonelReaderClassDefinition withAll: anArray [


	self classDefinitions at: aTonelReaderClassDefinition put: anArray
]

{
	#category : 'operations',
	#vaVisibility : 'private'
}
TonelReaderPackageDefinition >> addExtension: aTonelReaderClassExtensionDefinition withAll: anArray [


	self extensions at: aTonelReaderClassExtensionDefinition put: anArray
	
]

{
	#category : 'accessing'
}
TonelReaderPackageDefinition >> appName [

	^self name copyWithout: $-
]

{
	#category : 'accessing'
}
TonelReaderPackageDefinition >> classDefinitions [

	^classDefinitions ifNil: [classDefinitions := Dictionary new]
]

{
	#category : 'accessing'
}
TonelReaderPackageDefinition >> definedClasses [

	^self classDefinitions keys
]

{
	#category : 'accessing'
}
TonelReaderPackageDefinition >> extendedClasses [
	"Enter the new method definition below and click 'Resume'."
	
	^self extensions keys copy
]

{
	#category : 'accessing'
}
TonelReaderPackageDefinition >> extensions [

	^extensions ifNil: [extensions := Dictionary new]
]

{
	#category : 'initializing',
	#vaVisibility : 'private'
}
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

{
	#category : 'accessing'
}
TonelReaderPackageDefinition >> metadata [
	^metadata ifNil: [metadata := Dictionary new]
]

{
	#category : 'accessing'
}
TonelReaderPackageDefinition >> parent [
	^self metadata at: #vaParent ifAbsent: [nil]
]
