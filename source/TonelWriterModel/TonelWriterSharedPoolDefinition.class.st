Class {
	#name : 'TonelWriterSharedPoolDefinition',
	#superclass : 'TonelWriterShadowClassDefinition',
	#instVars : [
		'poolName'
	],
	#category : 'TonelWriterModel'
}

{
	#category : 'Not categorized'
}
TonelWriterSharedPoolDefinition class >> of: aClass definedIn: anApplication [

	self shouldNotImplement
]

{
	#category : 'Not categorized'
}
TonelWriterSharedPoolDefinition class >> of: aClass named: aSymbol definedIn: anApplication [

	^self new initializeOf: aClass named: aSymbol definedIn: anApplication
]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> applicationName [

	^application definedApplication asString
]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> classInstanceVariableNames [

	^#()
]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> classVariableNames [

	^self pool keys reject: [:each | each first = $! ]
]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> createInitializationMethod: selector [

	| method |

	method :=
		TonelWriterSharedPoolInitializationMethodDefinition
			uniquelyKnownAs: selector
			in: self
			categorizedAs: (
				String streamContents: [:stream |
					stream
						nextPut: $';
						nextPutAll: 'Initializing';
						nextPut: $']).
	method application: application.
	^method
]

{
	#category : 'Not categorized'
}
TonelWriterSharedPoolDefinition >> defaultInitializationMethod [

	^TonelWriterSharedPoolDefaultInitializationMethodDefinition
		uniquelyKnownAs: #initialize
		in: self
		categorizedAs: (
			String streamContents: [:stream |
				stream
					nextPut: $';
					nextPutAll: 'Initializing';
					nextPut: $'])


]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> definedClassName [

	^poolName
]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> definedClassSuperclassName [

	^#SharedPool

]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> fileName [

	^'<1s>.class.st' expandMacrosWith: poolName asString
]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> initializeOf: aClass named: aSymbol definedIn: anApplication [

	class := aClass.
	poolName := aSymbol.
	application := anApplication
]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> instanceVariableNames [

	^#()
]

{
	#category : 'Accessing',
	#vaVisibility : 'private'
}
TonelWriterSharedPoolDefinition >> pool [
	"Private - Just a wrapper to the class instance variable to have semantic meaning in senders."

 	^class
]

{
	#category : 'Accessing'
}
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

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> poolNames [

	^#()
]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> subclassType [

	^'variable'
]

{
	#category : 'Accessing'
}
TonelWriterSharedPoolDefinition >> withFormattedCommentDo: aBlock [

	
]
