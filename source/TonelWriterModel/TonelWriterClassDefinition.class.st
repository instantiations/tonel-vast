Class {
	#name : 'TonelWriterClassDefinition',
	#superclass : 'Object',
	#instVars : [
		'class',
		'application'
	],
	#category : 'TonelWriterModel'
}

{
	#category : 'Instance Creation'
}
TonelWriterClassDefinition class >> of: aClass definedIn: anApplication [

	| inst |

	inst := aClass isLoaded ifTrue: [self new] ifFalse: [TonelWriterShadowClassDefinition new].
	^inst initializeOf: aClass definedIn: anApplication
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> applicationName [

	^application asString
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> classInstanceVariableNames [

	^class class instVarNames
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> classVariableNames [

	^class classVarNames
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> definedClassName [

	^class name
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> definedClassSuperclassName [

	^class superclass ifNil: [#nil] ifNotNil: [class superclass name]
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> definitionRecord [

	^class definitionRecord
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> fileName [

	^'<1s>.class.st' expandMacrosWith: class asString
]

{
	#category : 'Printing',
	#vaVisibility : 'private'
}
TonelWriterClassDefinition >> formattedCategoryOf: selector in: aClassOrMetaclass [

	| category |

	category := (aClassOrMetaclass categoriesFor: selector) asSortedCollection first.

	^String streamContents: [:stream |
		stream
			nextPut: $';
			nextPutAll: category;
			nextPut: $']
]

{
	#category : 'Defaults'
}
TonelWriterClassDefinition >> hasDefaultSubclassType [

	^self subclassType asString = 'pointers'
]

{
	#category : 'Initialization',
	#vaVisibility : 'private'
}
TonelWriterClassDefinition >> initializeOf: aClass definedIn: anApplication [

	class := aClass.
	application := anApplication
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> instanceVariableNames [

	^class instVarNames
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> isTonelSpecialSelector: aSymbol [
	"Answer whether aSymbol matches a method used for compatibility or utility in Tonel."
	
	^'_SHAREDPOOL_*' match: aSymbol
]

{
	#category : 'Accessing',
	#vaVisibility : 'private'
}
TonelWriterClassDefinition >> methodDefinitionsOf: aClassOrMetaclass [

	^((aClassOrMetaclass allSelectorsFor: aClassOrMetaclass controller) 
		reject: [:each | self isTonelSpecialSelector: each]) collect: 
				[:selector | 
				TonelWriterMethodDefinition 
					uniquelyKnownAs: selector
					in: aClassOrMetaclass
					categorizedAs: (self formattedCategoryOf: selector in: aClassOrMetaclass)]
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> poolNames [

	^class = application
		ifTrue: [
			(application class selectors
				select: [:each | EmNamespaceSupport declarationPattern match: each asString])
					collect: [:selector |
						selector
							copyFrom: EmNamespaceSupport declarationPattern size
							to: selector size]]
		ifFalse: [class sharedPoolNames]
]

{
	#category : 'Printing'
}
TonelWriterClassDefinition >> printOn: aStream [

	aStream nextPutAll: ('Tonel class definition of <1p>' expandMacrosWith: class)
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> subclassType [

	^self definitionRecord tonelKindOfSubclass
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> withClassMethodDefinitionsDo: aBlock [

	self
		withMethodDefinitionsOf: class class
		do: [:methodDefinition | aBlock value: methodDefinition]
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> withFormattedCommentDo: aBlock [

	class comment notEmpty ifTrue: [aBlock value: (class comment copyReplaceAll: '"' with: '""')]
]

{
	#category : 'Accessing'
}
TonelWriterClassDefinition >> withInstanceMethodDefinitionsDo: aBlock [

	self withMethodDefinitionsOf: class do: [:methodDefinition | aBlock value: methodDefinition]
]

{
	#category : 'Accessing',
	#vaVisibility : 'private'
}
TonelWriterClassDefinition >> withMethodDefinitionsOf: aClassOrMetaclass do: aBlock [

	(self methodDefinitionsOf: aClassOrMetaclass)
		do: [:methodDefinition | aBlock value: methodDefinition]
]
