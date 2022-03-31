Class {
	#name : 'TonelReaderClassExtensionDefinition',
	#superclass : 'TonelReaderAbstractClassDefinition',
	#category : 'TonelReaderModel'
}

{ #category : 'constants' }
TonelReaderClassExtensionDefinition class >> definitionType [
	"Answer the definition type of receiver instances."
	
	^'Extension'
]

{ #category : 'testing' }
TonelReaderClassExtensionDefinition >> = classDefinition [
	"Answer whether receiver is equal to classDefinition."

	^(self class = classDefinition class) and: [
			(name = classDefinition name) and: [
				self superclassIdentifier = classDefinition superclassIdentifier]]
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

{ #category : 'comparing' }
TonelReaderClassExtensionDefinition >> hash [
	"Answer a positive SmallInteger that represents the
	 receiver. Objects that are equivalent (=) must answer
	 the same value for the message #hash.
	 
	 Answers:
		<Integer>
	 "

	^self identifier hash bitXor:  self superclassIdentifier hash
]

{ #category : 'accessing' }
TonelReaderClassExtensionDefinition >> identifier [

	^self name asSymbol
]

{ #category : 'accessing' }
TonelReaderClassExtensionDefinition >> superclassIdentifier [
	
	^nil
]
