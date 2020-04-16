Class {
	#name : 'TonelWriterAbstractClassDefinition',
	#superclass : 'Object',
	#instVars : [
		'class',
		'application'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'accessing' }
TonelWriterAbstractClassDefinition >> fileName [

	self subclassResponsibility
]

{ #category : 'Printing',
  #vaVisibility : 'private' }
TonelWriterAbstractClassDefinition >> formattedCategoryOf: selector in: aClassOrMetaclass [

	^(aClassOrMetaclass categoriesFor: selector) asSortedCollection first.
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterAbstractClassDefinition >> isTonelSpecialSelector: aSymbol [
	"Answer whether aSymbol matches a method used for compatibility or utility in Tonel."

	^('_SHAREDPOOL_*' match: aSymbol) or: ['_TONEL_*' match: aSymbol]
]
