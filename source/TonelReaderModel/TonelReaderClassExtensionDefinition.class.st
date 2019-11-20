Class {
	#name : 'TonelReaderClassExtensionDefinition',
	#superclass : 'TonelReaderAbstractClassDefinition',
	#category : 'TonelReaderModel'
}

{ #category : 'constants' }
TonelReaderClassExtensionDefinition class >> definitionType [

	^'Extension'
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelReaderClassExtensionDefinition >> addToPackage: packageDefinition withAll: anArray [

	
	tonelMethods := anArray asOrderedCollection.
	packageDefinition addExtension: self withAll: anArray
]

{ #category : 'testing' }
TonelReaderClassExtensionDefinition >> extension [
	"Answer whether receiver represents a class extension."
	
	^true
]

{ #category : 'accessing' }
TonelReaderClassExtensionDefinition >> identifier [

	^self name asSymbol
]

{ #category : 'testing' }
TonelReaderClassExtensionDefinition >> isSharedPool [
	
	^false
]
