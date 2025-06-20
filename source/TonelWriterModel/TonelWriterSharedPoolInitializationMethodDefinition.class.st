Class {
	#name : 'TonelWriterSharedPoolInitializationMethodDefinition',
	#superclass : 'TonelWriterMethodDefinition',
	#instVars : [
		'application'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'accessing' }
TonelWriterSharedPoolInitializationMethodDefinition >> application: aTonelWriterApplicationDefinition [

	
	application := aTonelWriterApplicationDefinition
	
]

{ #category : 'accessing' }
TonelWriterSharedPoolInitializationMethodDefinition >> compiledMethod [

	^application definedApplication class >> selector
]

{ #category : 'accessing' }
TonelWriterSharedPoolInitializationMethodDefinition >> definitionClassName [

	^self pool definedClassName, ' class'
]

{ #category : 'testing' }
TonelWriterSharedPoolInitializationMethodDefinition >> hasDefaultVACategories [

	^true
]

{ #category : 'testing' }
TonelWriterSharedPoolInitializationMethodDefinition >> isVirtual [
	"Answer whether receiver wraps an actual compiled method."
	
	^true
]

{ #category : 'accessing' }
TonelWriterSharedPoolInitializationMethodDefinition >> methodBody [

	| sourceString bodyStream |

	sourceString := self compiledMethod tonelSourceString.
	bodyStream :=
		(sourceString copyFrom: selector size + CldtConstants::LineDelimiter size + 1 to: sourceString size) readStream.

	^bodyStream
		skipSeparators;
		contents
]

{ #category : 'accessing' }
TonelWriterSharedPoolInitializationMethodDefinition >> methodDeclaration [

	| selectorParts |
	selectorParts := selector subStrings: $_.
	^$_ join: (selectorParts copyFrom: 3 to: selectorParts size).
]

{ #category : 'accessing' }
TonelWriterSharedPoolInitializationMethodDefinition >> pool [

	^definitionClass
]

{ #category : 'accessing' }
TonelWriterSharedPoolInitializationMethodDefinition >> visibilityString [

	^'public'
]

{ #category : 'writing' }
TonelWriterSharedPoolInitializationMethodDefinition >> writeUsing: aTonelMethodWriter on: aWriteStream [

	aTonelMethodWriter convertsSharedPools ifTrue: [
		super writeUsing: aTonelMethodWriter on: aWriteStream ]
]
