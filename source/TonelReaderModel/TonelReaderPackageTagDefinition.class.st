"
TonelReaderPackageTagDefinition works as a ""virtual"" package that we create 
to map classes defined in a Package tag to VAST Subapplications.

Read more about how the mapping works at:
<https://github.com/instantiations/tonel-vast/blob/master/docs/strategies.md#package-tags-and-subapplications-strategy>
"
Class {
	#name : 'TonelReaderPackageTagDefinition',
	#superclass : 'TonelReaderPackageDefinition',
	#instVars : [
		'tag',
		'package'
	],
	#category : 'TonelReaderModel'
}

{ #category : 'Instance creation' }
TonelReaderPackageTagDefinition class >> package: aTonelPackageDefinition tag: aSymbol [
	"Answer a new instance of receiver belonging to aTonelPackageDefinition
	 with aSymbol as its tag."

	^self new
		package: aTonelPackageDefinition;
		tag: aSymbol;
		yourself
]

{ #category : 'accessing' }
TonelReaderPackageTagDefinition >> package [
	^package
]

{ #category : 'accessing' }
TonelReaderPackageTagDefinition >> package: anObject [
	package := anObject
]

{ #category : 'accessing' }
TonelReaderPackageTagDefinition >> tag [
	^tag
]

{ #category : 'accessing' }
TonelReaderPackageTagDefinition >> tag: anObject [
	tag := anObject
]
