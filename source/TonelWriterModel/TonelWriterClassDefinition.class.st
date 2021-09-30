Class {
	#name : 'TonelWriterClassDefinition',
	#superclass : 'TonelWriterAbstractClassDefinition',
	#instVars : [
		'packageName',
		'tag'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Instance Creation' }
TonelWriterClassDefinition class >> of: aClass definedIn: anApplication [

	| inst |

	inst := aClass isLoaded ifTrue: [self new] ifFalse: [TonelWriterShadowClassDefinition new].
	^inst initializeOf: aClass definedIn: anApplication
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> applicationName [

	^application asString
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> category [
	
	^self hasTag
		ifTrue: [self packageName, '-', self tag]
		ifFalse: [self packageName]
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> classInstanceVariableNames [

	^class class instVarNames
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> classVariableNames [

	^class classVarNames
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> definedClassName [

	^class name
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> definedClassSuperclassName [

	^class superclass ifNil: [#nil] ifNotNil: [class superclass name]
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> definitionRecord [

	^class definitionRecord
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> fileName [

	^'<1s>.class.st' expandMacrosWith: class asString
]

{ #category : 'Defaults' }
TonelWriterClassDefinition >> hasDefaultSubclassType [

	^self subclassType asString = 'pointers'
]

{ #category : 'Testing' }
TonelWriterClassDefinition >> hasTag [

	^self tag isEmptyOrNil not
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelWriterClassDefinition >> initializeOf: aClass definedIn: anApplication [

	class := aClass.
	application := anApplication
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> instanceVariableNames [

	^class instVarNames
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterClassDefinition >> methodDefinitionsOf: aClassOrMetaclass [

	^((aClassOrMetaclass allSelectorsFor: aClassOrMetaclass controller) 
		reject: [:each | self isTonelSpecialSelector: each]) collect: 
				[:selector | 
				TonelWriterMethodDefinition 
					uniquelyKnownAs: selector
					in: aClassOrMetaclass
					categorizedAs: (self formattedCategoryOf: selector in: aClassOrMetaclass)]
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> packageName [
	^packageName ifNil: [packageName := self tonelPackageName]
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> packageName: anObject [
	packageName := anObject
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> poolNames [

	^class sharedPoolNames
]

{ #category : 'Printing' }
TonelWriterClassDefinition >> printOn: aStream [

	aStream nextPutAll: ('Tonel class definition of <1p>' expandMacrosWith: class)
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> subclassType [

	^self definitionRecord tonelKindOfSubclass
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> tag [
	^tag
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> tag: anObject [
	tag := anObject
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> tonelPackageName [

	^application tonelPackageName
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> withClassMethodDefinitionsDo: aBlock [

	self
		withMethodDefinitionsOf: class class
		do: [:methodDefinition | aBlock value: methodDefinition]
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> withFormattedCommentDo: aBlock [

	class comment notEmpty ifTrue: [aBlock value: (class comment copyReplaceAll: '"' with: '""')]
]

{ #category : 'accessing' }
TonelWriterClassDefinition >> withInstanceMethodDefinitionsDo: aBlock [

	self withMethodDefinitionsOf: class do: [:methodDefinition | aBlock value: methodDefinition]
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterClassDefinition >> withMethodDefinitionsOf: aClassOrMetaclass do: aBlock [

	(self methodDefinitionsOf: aClassOrMetaclass)
		do: [:methodDefinition | aBlock value: methodDefinition]
]
