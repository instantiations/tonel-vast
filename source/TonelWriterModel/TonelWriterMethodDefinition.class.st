Class {
	#name : 'TonelWriterMethodDefinition',
	#superclass : 'Object',
	#instVars : [
		'category',
		'selector',
		'definitionClass'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Instance Creation' }
TonelWriterMethodDefinition class >> uniquelyKnownAs: aSymbol in: aClass categorizedAs: aCategory [

	^self new initializeUniquelyKnownAs: aSymbol in: aClass categorizedAs: aCategory
]

{ #category : 'accessing' }
TonelWriterMethodDefinition >> allCategories [

	^definitionClass categoriesFor: selector
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterMethodDefinition >> basicCategory [

	^category
]

{ #category : 'accessing' }
TonelWriterMethodDefinition >> category [

	^category
]

{ #category : 'accessing' }
TonelWriterMethodDefinition >> categoryFor: aTonelWriter [
	"Answer the category used in a TonelWriter."

	^(self isMonticelloExtension and: [aTonelWriter useMonticelloExtensions not])
		ifTrue: [self allCategories first]
		ifFalse: [self category]



]

{ #category : 'accessing' }
TonelWriterMethodDefinition >> compiledMethod [

	^definitionClass >> selector
]

{ #category : 'accessing' }
TonelWriterMethodDefinition >> definitionClass [

	^definitionClass
]

{ #category : 'accessing' }
TonelWriterMethodDefinition >> definitionClassName [

	^self definitionClass name
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> hasDefaultVACategories [
	"Answer whether receiver should write the categories into aCollection."
	"NOTE:
	 If there is only one category, no need to write #vaCategories key as we are
	 already writing #category:.
	 In the case of extension methods the first in allCategories will be the real one in VA
	 while the one of #category will be one with *X compatible with Tonel/Pharo"

	^self allCategories size = 1 and: [(self allCategories first match: self category)]
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> hasDefaultVAVisibility [

	^self visibilityString = 'public'
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> hasMultipleCategories [
	"Answer whether receiver has more than one category."

	^self allCategories size > 1
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelWriterMethodDefinition >> initializeUniquelyKnownAs: aSymbol in: aClass categorizedAs: aCategory [

	definitionClass := aClass.
	selector := aSymbol.
	category := aCategory
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> isMonticelloExtension [
		
	^self basicCategory beginsWithSubCollection: '*'
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> isPoolPragma [
	"Answer whether receiver compiled method is a declaration of a Pool Dictionary."

	^(EmNamespaceSupport declarationPattern match: selector )
		and: 
				[(self methodBody trimSeparators 
					beginsWithSubCollection: '"%%PRAGMA DECLARE') 
						and: [self methodBody includesSubstring: 'isPool: true']]
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> isRealPragma [
		
	^self isVirtual not and: [self isPoolPragma]
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> isVirtual [
	"Answer whether receiver wraps an actual compiled method."
	
	^false
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> isVirtualPragma [
		
	^self isVirtual and: [self isPoolPragma]
]

{ #category : 'accessing' }
TonelWriterMethodDefinition >> methodBody [

	| result body bodyStream messagePattern foundFirstChar sourceString |
	sourceString :=  self compiledMethod tonelSourceString.
	result :=
		EsCompiler
			parse: sourceString
			environment: (EsCompiler nameEnvironmentForClass: self compiledMethod methodClass)
			messagePattern: true
			scanComments: false
			errorHandler: EsSilentErrorHandler new.

	messagePattern := result parseTree messagePattern.
	bodyStream :=
		 (sourceString
			copyFrom: (messagePattern sourceEnd + 1)
			to: result parseTree sourceEnd)
				readStream.


	[bodyStream atEnd not and: [{ Character space. Character tab } includes: bodyStream peek]] whileTrue: [bodyStream next].
	(bodyStream atEnd not and: [(CldtConstants::LineDelimiter) includes: bodyStream peek]) ifTrue: [bodyStream next].
	(bodyStream atEnd not and: [bodyStream peek isSeparator]) ifTrue: [bodyStream next].
	body := bodyStream upToEnd.
	^body
]

{ #category : 'accessing' }
TonelWriterMethodDefinition >> methodDeclaration [

	| result declaration messagePattern |

	result := EsCompiler
		parse: self compiledMethod tonelSourceString
		environment: (EsCompiler nameEnvironmentForClass: self compiledMethod methodClass)
		messagePattern: true
		scanComments: false
		errorHandler: EsSilentErrorHandler new.
		
	messagePattern := result parseTree messagePattern.
	declaration := messagePattern asString trimBoth: [:char | char isSeparator].
	^declaration
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterMethodDefinition >> pragmaPrefix [
	| pattern |
	pattern := EmNamespaceSupport declarationPattern.
	^pattern copyFrom: 1 to: pattern size - 1.
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterMethodDefinition >> pragmaSuffix [

	^selector copyFrom: (self pragmaPrefix size + 1 min: selector size) to: selector size
]

{ #category : 'printing' }
TonelWriterMethodDefinition >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(#';
		nextPutAll: selector asString;
		nextPut: $)
]

{ #category : 'accessing' }
TonelWriterMethodDefinition >> visibilityString [

	^self compiledMethod isPrivate ifTrue: ['private'] ifFalse: ['public']
]

{ #category : 'writing' }
TonelWriterMethodDefinition >> writeUsing: aTonelMethodWriter on: aWriteStream [

	(self isPoolPragma not or: [self isPoolPragma and: [aTonelMethodWriter parent convertsSharedPools not]]) ifTrue: [
		aTonelMethodWriter write: self on: aWriteStream
	]
]
