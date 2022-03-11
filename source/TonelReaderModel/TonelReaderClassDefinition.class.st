Class {
	#name : 'TonelReaderClassDefinition',
	#superclass : 'TonelReaderAbstractClassDefinition',
	#instVars : [
		'identifier',
		'extension',
		'fieldType',
		'variableClass',
		'superclassIdentifier',
		'classComment',
		'instanceVariables',
		'classVariables',
		'classInstanceVariables',
		'poolDictionaries',
		'methods',
		'isSharedPool',
		'category'
	],
	#category : 'TonelReaderModel'
}

{ #category : 'constants' }
TonelReaderClassDefinition class >> definitionType [
	"Answer the definition type of receiver instances."

	^'Class' "$NON-NLS$"
]

{ #category : 'Initialize-Release' }
TonelReaderClassDefinition class >> name: aString [
	"Answer a new instance of receiver with aString as its name."
	
	^self new
		initialize: aString;
		yourself
]

{ #category : 'Initialize-Release' }
TonelReaderClassDefinition class >> name: nameString superclass: superString variable: varBoolean fieldType: fieldTypeString instanceVariables: instVarString classVariables: classVarString poolDictionaries: poolDictString [
	"Answer a new instance of receiver with all the parameters 
	 specified as arguments."

	^self new
		initializeWithName: nameString 
		superclass: superString 
		variable: varBoolean
		fieldType: fieldTypeString
		instanceVariables: instVarString 
		classVariables: classVarString 
		poolDictionaries: poolDictString;
		yourself

]

{ #category : 'comparing' }
TonelReaderClassDefinition >> = classDefinition [


	^classDefinition notNil and: [
		(name = classDefinition name) and: [
			superclassIdentifier = classDefinition superclassIdentifier and: [
				category = classDefinition category and: [
					fieldType = classDefinition fieldType and: [
						instanceVariables = classDefinition instanceVariables and: [
							classComment = classDefinition classComment and: [
								classVariables = classDefinition classVariables and: [
									classInstanceVariables =
										classDefinition classInstanceVariables
											and: [
												poolDictionaries =
													classDefinition poolDictionaries]]]]]]]]]
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> addMethod: aTonelMethodDefinition [

	tonelMethods add: aTonelMethodDefinition
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> addToPackage: packageDefinition withAll: anArray [

	
	tonelMethods := anArray asOrderedCollection.
	packageDefinition addClassDefinition: self withAll: anArray
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> category [

	^category ifNil: [category := '']
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> category: aString [

	category := aString
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> classComment [

	^ classComment ifNil: [classComment := '']  "$NON-NLS$"
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> classComment: aString [
	classComment := aString
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> classInstanceVariables [

	^ classInstanceVariables ifNil: [ classInstanceVariables := '' ]	"$NON-NLS$"
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> classInstanceVariables: aString [
	classInstanceVariables := aString
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> classVariables [
	^classVariables
]

{ #category : 'Initialize-Release',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> computeWhetherSharedPool [
	^self superclassIdentifier = #SharedPool
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> extension [
	"Answer whether receiver represents a class extension."

	^false
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> fieldType [

	^ fieldType ifNil: [ fieldType := 'pointers' ]  "$NON-NLS$"
]

{ #category : 'testing' }
TonelReaderClassDefinition >> hasTagForPackageNamed: packageName [

	^self category beginsWithSubCollection: packageName , '-'
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> identifier [
	^identifier
]

{ #category : 'testing' }
TonelReaderClassDefinition >> includesClassSideNewMethod [

	^(self tonelMethods
		detect: [:each | each isClassSide and: [each selector = #new]]
		ifNone: [nil])
			notNil
]

{ #category : 'Initialize-Release' }
TonelReaderClassDefinition >> initialize: aString [
	name := aString.
	identifier := aString asSymbol.
	tonelMethods  := OrderedCollection new.
	isSharedPool := false
]

{ #category : 'Initialize-Release' }
TonelReaderClassDefinition >> initializeWithName: nameString superclass: superString variable: varBoolean fieldType: fieldTypeString instanceVariables: instVarString classVariables: classVarString poolDictionaries: poolDictString [
	
	name := nameString.
	identifier := nameString asSymbol.
	superclassIdentifier := superString asSymbol = #nil ifTrue: [nil] ifFalse: [superString asSymbol].
	variableClass := varBoolean.
	fieldType := fieldTypeString.
	instanceVariables := instVarString.
	classInstanceVariables := #().	"If the class has class instance variables, they are provided separately"
	classVariables := classVarString.
	poolDictionaries := poolDictString.
	extension := false.
	tonelMethods := OrderedCollection new.
	

]

{ #category : 'accessing' }
TonelReaderClassDefinition >> instanceVariables [
	^instanceVariables
	
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> packageTagIn: packageName [

	| classCategory |

	classCategory := self category asString.
	^(self hasTagForPackageNamed: packageName)
		ifTrue: [
			(packageName endsWithSubCollection: 'App')
				ifTrue: [packageName size + 3 + 2]
				ifFalse: [packageName size + 2].
			classCategory copyFrom: packageName size + 2 to: classCategory size]
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> poolDictionaries [
	^poolDictionaries
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> superclassIdentifier [
	^superclassIdentifier
]

{ #category : 'accessing' }
TonelReaderClassDefinition >> variableClass [

	^variableClass ifNil: [variableClass := false]
]
