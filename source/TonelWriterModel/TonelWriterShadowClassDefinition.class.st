Class {
	#name : 'TonelWriterShadowClassDefinition',
	#superclass : 'TonelWriterClassDefinition',
	#category : 'TonelWriterModel'
}

{ #category : 'accessing' }
TonelWriterShadowClassDefinition >> classInstanceVariableNames [

	^self definitionRecord classInstVarNames
]

{ #category : 'accessing' }
TonelWriterShadowClassDefinition >> classVariableNames [

	^self definitionRecord classVarNames
]

{ #category : 'accessing' }
TonelWriterShadowClassDefinition >> definedClassSuperclassName [

	^self definitionRecord superclassName ifNil: [#nil]

]

{ #category : 'accessing' }
TonelWriterShadowClassDefinition >> instanceVariableNames [

	^self definitionRecord instVarNames
]

{ #category : 'accessing' }
TonelWriterShadowClassDefinition >> poolNames [

	^self definitionRecord sharedPoolNames
]
