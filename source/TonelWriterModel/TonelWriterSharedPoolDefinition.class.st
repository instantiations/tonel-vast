Class {
	#name : 'TonelWriterSharedPoolDefinition',
	#superclass : 'TonelWriterShadowClassDefinition',
	#instVars : [
		'poolName',
		'declarationMethod'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Not categorized' }
TonelWriterSharedPoolDefinition class >> declaredBy: methodDefinition definedIn: anApplication [

	
	^self new
			setDeclarationMethod: methodDefinition application: anApplication;
			yourself
]

{ #category : 'Not categorized' }
TonelWriterSharedPoolDefinition class >> of: aClass definedIn: anApplication [

	self shouldNotImplement
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> applicationName [

	^application definedApplication asString
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> classInstanceVariableNames [

	^#()
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> classVariableNames [

	^(self poolDeclarations reject: [:each | each name first = $! ]) collect: [:declaration | declaration name ]
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> createInitializationMethod: selector [

	| method |

	method :=
		TonelWriterSharedPoolInitializationMethodDefinition
			uniquelyKnownAs: selector
			in: self
			categorizedAs: 'Initializing'.
	method application: application.
	^method
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> declarationMethod [
	
	^declarationMethod
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelWriterSharedPoolDefinition >> defaultInitializationMethod [

	| initializationMethod |
	initializationMethod := TonelWriterSharedPoolDefaultInitializationMethodDefinition
		uniquelyKnownAs: #initialize
		in: self
		categorizedAs: 'Initializing'.
	initializationMethod application: application.
	^initializationMethod
	


]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> definedClassName [

	^poolName
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> definedClassSuperclassName [

	^#SharedPool

]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> fileName [

	^'<1s>.class.st' expandMacrosWith: poolName asString
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> instanceVariableNames [

	^#()
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelWriterSharedPoolDefinition >> pool [
	"Private - Just a wrapper to the class instance variable to have semantic meaning in senders."

 	^class
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> poolDeclarations [

	| declarations |
	declarations := EmNamespaceManagement getVariableDeclarationsFromMethod: declarationMethod  compiledMethod
	contextParameters:  (Array with: application asString with: declarationMethod definitionClassName with: declarationMethod methodDeclaration asSymbol).
	^declarations select: [: each | each isPoolVariable ]
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> poolInitializationMethods [
	"Returns the methods used to initialize the values of the shared pool. Or create a default if needed."

	| initializationMethods |

	initializationMethods := OrderedCollection new.
	application definedApplication class methodDictionary keysAndValuesDo: [:selector :compiledMethod |
		(('_SHAREDPOOL_' , poolName , '_*') match: selector)
			ifTrue: [initializationMethods add: (self createInitializationMethod: selector)]].
	initializationMethods isEmpty ifTrue: [initializationMethods add: self defaultInitializationMethod].
	^initializationMethods
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> poolNames [

	^#()
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelWriterSharedPoolDefinition >> setDeclarationMethod: methodDefinition application: anApplication [

	declarationMethod := methodDefinition.
	class := Smalltalk at: methodDefinition pragmaSuffix asSymbol.
	poolName := methodDefinition pragmaSuffix asSymbol.
	application := anApplication.
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> subclassType [

	^'variable'
]

{ #category : 'Accessing' }
TonelWriterSharedPoolDefinition >> withFormattedCommentDo: aBlock [

	
]
