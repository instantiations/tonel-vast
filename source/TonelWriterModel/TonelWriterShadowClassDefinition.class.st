Class {
	#name : 'TonelWriterShadowClassDefinition',
	#superclass : 'TonelWriterClassDefinition',
	#category : 'TonelWriterModel'
}

{ #category : 'Accessing' }
TonelWriterShadowClassDefinition >> classInstanceVariableNames [

	^self definitionRecord classInstVarNames
]

{ #category : 'Accessing' }
TonelWriterShadowClassDefinition >> classVariableNames [

	^self definitionRecord classVarNames
]

{ #category : 'Accessing' }
TonelWriterShadowClassDefinition >> definedClassSuperclassName [

	^self definitionRecord superclassName ifNil: [#nil]

]

{ #category : 'Accessing' }
TonelWriterShadowClassDefinition >> instanceVariableNames [

	^self definitionRecord instVarNames
]

{ #category : 'Accessing' }
TonelWriterShadowClassDefinition >> poolNames [

	^self definitionRecord sharedPoolNames
]
