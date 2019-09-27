Class {
	#name : 'TonelWriterSharedPoolInitializationMethodDefinition',
	#superclass : 'TonelWriterMethodDefinition',
	#instVars : [
		'application'
	],
	#category : 'TonelWriterModel'
}

{
	#category : 'accessing'
}
TonelWriterSharedPoolInitializationMethodDefinition >> application: aTonelWriterApplicationDefinition [

	
	application := aTonelWriterApplicationDefinition
	
]

{
	#category : 'accessing'
}
TonelWriterSharedPoolInitializationMethodDefinition >> className [

	^self pool definedClassName, ' class'
]

{
	#category : 'accessing'
}
TonelWriterSharedPoolInitializationMethodDefinition >> compiledMethod [

	^application definedApplication class >> selector
]

{
	#category : 'testing'
}
TonelWriterSharedPoolInitializationMethodDefinition >> hasDefaultVACategories [

	^true
]

{
	#category : 'testing'
}
TonelWriterSharedPoolInitializationMethodDefinition >> isVirtual [
	"Answer whether receiver wraps an actual compiled method."
	
	^true
]

{
	#category : 'accessing'
}
TonelWriterSharedPoolInitializationMethodDefinition >> methodDeclaration [

	| selectorParts |
	selectorParts := selector subStrings: $_.
	^$_ join: (selectorParts copyFrom: 3 to: selectorParts size).
]

{
	#category : 'accessing'
}
TonelWriterSharedPoolInitializationMethodDefinition >> pool [

	^class
]

{
	#category : 'accessing'
}
TonelWriterSharedPoolInitializationMethodDefinition >> visibilityString [

	^'public'
]
