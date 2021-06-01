Class {
	#name : 'TonelReaderPackageTagDefinition',
	#superclass : 'TonelReaderPackageDefinition',
	#instVars : [
		'tag',
		'package'
	],
	#category : 'TonelReaderModel'
}

{ #category : 'Not categorized' }
TonelReaderPackageTagDefinition class >> package: aTonelPackageDefinition tag: aSymbol [

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
