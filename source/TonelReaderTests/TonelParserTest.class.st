Class {
	#name : 'TonelParserTest',
	#superclass : 'TestCase',
	#category : 'TonelReaderTests'
}

{ #category : 'instance creation' }
TonelParserTest class >> new [

	^super new initialize
]

{ #category : 'asserting' }
TonelParserTest >> assertParse: aString rule: rule equals: result [
	self assert: (self parse: aString rule: rule) equals: result
]

{ #category : 'private' }
TonelParserTest >> parse: aString rule: rule [
	| parser |
	parser := TonelParser on: aString readStream.
	^ parser perform: rule
]

{ #category : 'asserting' }
TonelParserTest >> shouldParse: aString rule: rule raise: error [
	| parser |
	parser := TonelParser on: aString readStream.
	self should: [ parser perform: rule ] raise: error
]

{ #category : 'tests' }
TonelParserTest >> testClassDefBytesType [

	self
		assertParse:
			'
"
this is a test
"
Class { 
	#name: ''X'',
	#superclass: ''Y'',
	#category: ''Z'',
	#type : ''bytes''
}'
		rule: #typeDef
		equals: (
			(TonelReaderClassDefinition
				name: 'X'
				superclass: 'Y'
				variable: nil
				fieldType: 'bytes'
				instanceVariables: #()
				classVariables: #()
				poolDictionaries: #())
					category: 'Z';
					classComment: 'this is a test';
					yourself)


]

{ #category : 'tests' }
TonelParserTest >> testClassDefFullyDefined [

	self
		assertParse:
			'"I''m a the class comment with quotes"
Class {
	#name : ''X'',
	#superclass : ''Y'',
	#instVars : [
		''instVar1'',
		''instVar2'',
		''instVar3''
	],
	#classVars : [
		''ClassVar1'',
		''ClassVar2'',
		''ClassVar3''
	],
	#pools : [
		''P''
	],
	#classInstVars : [
		''classInstVar1'',
		''classInstVar2'',
		''classInstVar3''
	],
	#category : ''Z''
}'
		rule: #typeDef
		equals: (
			(TonelReaderClassDefinition
				name: 'X'
				superclass: 'Y'
				variable: nil
				fieldType: 'pointers'
				instanceVariables: #('instVar1' 'instVar2' 'instVar3')
				classVariables: #('ClassVar1' 'ClassVar2' 'ClassVar3')
				poolDictionaries: #('P'))
					category: 'Z';
					classInstanceVariables: #('classInstVar1' 'classInstVar2' 'classInstVar3');
					classComment: 'I''m a the class comment with quotes';
					yourself)


]

{ #category : 'tests' }
TonelParserTest >> testClassDefVariableType [

	self
		assertParse:
			'
"
this is a test
"
Class { 
	#name: ''X'',
	#superclass: ''Y'',
	#category: ''Z'',
	#type : #variable
}'
		rule: #typeDef
		equals: (
			(TonelReaderClassDefinition
				name: 'X'
				superclass: 'Y'
				variable: nil
				fieldType: 'pointers'
				instanceVariables: #()
				classVariables: #()
				poolDictionaries: #())
					category: 'Z';
					classComment: 'this is a test';
					yourself)


]

{ #category : 'tests' }
TonelParserTest >> testComment [
	self
		shouldParse: 'this "should" be an error'
		rule: #comment
		raise: TonelParseError.
	self
		assertParse: '"this is a comment"'
		rule: #comment
		equals: 'this is a comment'.
	self
		assertParse: '"""this"" is a comment with ""nested"" colons ""also at the end"""'
		rule: #comment
		equals: '"this" is a comment with "nested" colons "also at the end"'
]

{ #category : 'tests' }
TonelParserTest >> testExtractSelector [
	| parser |
	
	parser := TonelParser new.
	
	self assert: (parser extractSelector: 'unary') equals: #unary.
	self assert: (parser extractSelector: '+ something') equals: #+.
	self assert: (parser extractSelector: '=> other') equals: #=>.
	self 
		assert: (parser extractSelector: 'some: arg1 keyword: arg2 selector: arg3') 
		equals: #some:keyword:selector:.
	self 
		assert: (parser extractSelector: 'some: 	arg1 keyword:arg2 selector: arg3') 
		equals: #some:keyword:selector:.
	self 
		assert: (parser extractSelector: 'some: arg1 
keyword: arg2 
selector: arg3') 
		equals: #some:keyword:selector:.
]

{ #category : 'tests' }
TonelParserTest >> testExtractSelectorWithComments [
	| parser |
	
	parser := TonelParser new.
	
	self assert: (parser extractSelector: 'unary "comment"') equals: #unary.
	self assert: (parser extractSelector: '+ "comment" something') equals: #+.
	self assert: (parser extractSelector: '=> "comment" other') equals: #=>.
	self 
		assert: (parser extractSelector: 'some: arg1 "comment"  keyword: arg2  "comment" selector: arg3 "comment"') 
		equals: #some:keyword:selector:.
	self 
		assert: (parser extractSelector: 'some: 	arg1 "comment" keyword:arg2 selector: arg3') 
		equals: #some:keyword:selector:.
	self 
		assert: (parser extractSelector: 'some: arg1 "comment"
keyword: arg2 "comment"
selector: arg3') 
		equals: #some:keyword:selector:.
]

{ #category : 'tests' }
TonelParserTest >> testLiteralDollarCharacterAtEndOfLiteralArray [
	self assertParse: '[^#($$)]' rule: #methodBody equals: '^#($$)'
]

{ #category : 'tests' }
TonelParserTest >> testMaybeReturnADollar [
	self
		assertParse: '[self testSomething ifTrue: [^$$]]'
		rule: #methodBody
		equals: 'self testSomething ifTrue: [^$$]'
]

{ #category : 'tests' }
TonelParserTest >> testMetadata [

	self
		assertParse: '{ #vars: [ #a, #b ] }'
		rule: #metadata
		equals: (
			Dictionary new
				at: #vars put: #(a b);
				yourself).
	self
		assertParse: '{ 
	#vars: [ #a, #b ],
	#uses: { #someNested: 42 } 
	}'
		rule: #metadata
		equals: (
			(Dictionary new)
				at: #vars put: #(a b);
				at: #uses
					put: (
						Dictionary new
							at: #someNested put: 42;
							yourself);
				yourself)
]

{ #category : 'tests' }
TonelParserTest >> testMethod [
	self
		assertParse: 'Object>>name'
		rule: #method
		equals: #(#('Object' nil) 'name').
	self
		assertParse: 'Object >> name: aString'
		rule: #method
		equals: #(#('Object' nil) 'name: aString').
	self
		assertParse: 'Object >> name: aString [ I do not care ]'
		rule: #method
		equals: #(#('Object' nil) 'name: aString').
	self
		assertParse: 'Object class >> name: aString'
		rule: #method
		equals: #(#('Object' 'class') 'name: aString')
]

{ #category : 'tests' }
TonelParserTest >> testMethodBody [

	self
		assertParse: '[ method body... I will ignore what is inside ]'
		rule: #methodBody
		equals: ' method body... I will ignore what is inside'.
	self
		assertParse: '[
method 
	[body... [I 
		will ignore] 
what] is inside
]'
		rule: #methodBody
		equals: ('
method 
	[body... [I 
		will ignore] 
what] is inside').
	self
		assertParse: '[ method body with "''", ''"'', "[", '']'' ]'
		rule: #methodBody
		equals: ' method body with "''", ''"'', "[", '']'''
]

{ #category : 'tests' }
TonelParserTest >> testMethodBodyWithBlockContainingDollarCharacter [
	"https://github.com/pharo-vcs/tonel/issues/44"

	self assertParse: '[ $$ ]' rule: #methodBody equals: ' $$'.
	self assertParse: '[$$ ]' rule: #methodBody equals: '$$'.
	self assertParse: '[ $$]' rule: #methodBody equals: ' $$'.
	self assertParse: '[$$]' rule: #methodBody equals: '$$'
]

{ #category : 'tests' }
TonelParserTest >> testMethodBodyWithCommentNextToDollarCharLiteral [
	self
		assertParse: '[^$$"what about this one]"]'
		rule: #methodBody
		equals: '^$$"what about this one]"'
]

{ #category : 'tests' }
TonelParserTest >> testMethodBodyWithSquareBracketInsideLiteralArray [
	self
		assertParse: '[ "What about this valid literal Array guys" ^#( [ )]'
		rule: #methodBody
		equals: ' "What about this valid literal Array guys" ^#( [ )'
]

{ #category : 'tests' }
TonelParserTest >> testMethodBodyWithSquareBracketInsideLiteralArray2 [
	self
		assertParse:
			'[^#( "note that we need to prefix ) with $, but this is not necessary for ] and }" '')]}'' $) ] } )]'
		rule: #methodBody
		equals:
			'^#( "note that we need to prefix ) with $, but this is not necessary for ] and }" '')]}'' $) ] } )'
]

{ #category : 'tests' }
TonelParserTest >> testMethodBodyWithTrickyDollarCharLiteralInLiteralArray [
	self
		assertParse:
			'[^#( $$''please use space before this string)(''$$"please use space before this comment or avoid putting a ] in it"$$(this really is a literal array with a ] in it))]'
		rule: #methodBody
		equals:
			'^#( $$''please use space before this string)(''$$"please use space before this comment or avoid putting a ] in it"$$(this really is a literal array with a ] in it))'
]

{ #category : 'tests' }
TonelParserTest >> testMethodDef [

	self
		assertParse: '
{ #category: ''accessing'' }
Object>>name [
	^ self printString
]'
		rule: #methodDef
		equals: (
			(TonelReaderMethodDefinition
				className: 'Object'
				classSide: false
				categories: #('accessing')
				stamp: nil)
					source: 'name
	^ self printString';
					yourself).

	self
		assertParse: '
Object class>>name [ 
	^ self printString
]'
		rule: #methodDef
		equals: (
			(TonelReaderMethodDefinition className: 'Object' classSide: true categories: nil stamp: nil)
				source: 'name
	^ self printString';
				selector: #name;
				yourself)
]

{ #category : 'tests' }
TonelParserTest >> testMethodDefList [
	| parsed |
	parsed := self
		parse:
			'
Object class>>new [
	^ self basicNew initialize
]

{ #category: ''accessing'' }
Object>>name [
	^ self printString
]

{ #category: ''printing'' }
Object>>printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: [''an ''] ifFalse: [''a '']);
		nextPutAll: title

]'
		rule: #methodDefList.
	self assert: parsed size equals: 3
]

{ #category : 'tests' }
TonelParserTest >> testMethodDefPrivateCategory [

	self
		assertParse: '
{ #category: ''private'' }
Object>>name [
	^ self printString
]'
		rule: #methodDef
		equals: (
			(TonelReaderMethodDefinition
				className: 'Object'
				classSide: false
				categories: #('accessing')
				stamp: nil)
					source: 'name
	^ self printString';
					visibility: false;
					yourself)
]

{ #category : 'tests' }
TonelParserTest >> testMethodDefVACustomKeys [

	self
		assertParse: '
{
	#category : ''Accessing'',
	#vaCategories : [''Accessing'',''Real Category'',''Another One''],
	#vaVisibility : ''private''
}
Object>>name [
	^ self printString
]'
		rule: #methodDef
		equals: (
			(TonelReaderMethodDefinition
				className: 'Object'
				classSide: false
				categories: #('Accessing','Real Category','Another One')
				stamp: nil)
					source: 'name
	^ self printString';
					visibility: false;
					yourself)
]

{ #category : 'tests' }
TonelParserTest >> testType [
	self assertParse: 'Class' rule: #type equals: 'Class'.
	self assertParse: 'Extension' rule: #type equals: 'Extension'
]

{ #category : 'tests' }
TonelParserTest >> testTypeDef [

	self
		assertParse:
			'
"
this is a test
"
Class { 
	#name: ''X'',
	#superclass: ''Y'',
	#category: ''Z'' 
}'
		rule: #typeDef
		equals: (
			(TonelReaderClassDefinition
				name: 'X'
				superclass: 'Y'
				variable: nil
				fieldType: 'pointers'
				instanceVariables: #()
				classVariables: #()
				poolDictionaries: #())
					category: 'Z';
					classComment: 'this is a test';
					yourself)


]
