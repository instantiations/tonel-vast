Class {
	#name : 'TonelClassWriterTest',
	#superclass : 'TonelBaseTest',
	#category : 'TonelWriterTests'
}

{ #category : 'Initialization' }
TonelClassWriterTest >> setUp [

	super setUp.
	self writer:  
		(TonelClassWriter
			on: self fileSystem
			directory: self directoryForTestingPath
			lineDelimiter: TonelWriter lineDelimiter)
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClass [

	self writer write: (TonelWriterClassDefinition of: TonelMockB definedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/TonelMockB.class.st';
		assertContentsOfFileAt: '/TonelMockB.class.st'
			equals:
				'Class {
	#name : ''TonelMockB'',
	#superclass : ''Object'',
	#category : ''TonelWriterTests''
}
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassInSubApp [

	self writer write: (TonelWriterClassDefinition of: TonelMockD definedIn: TonelSubapplication).
	self
		assertFileSystemIncludesFileAt: '/TonelMockD.class.st';
		assertContentsOfFileAt: '/TonelMockD.class.st'
			equals:
				'Class {
	#name : ''TonelMockD'',
	#superclass : ''Object'',
	#category : ''TonelSubapplication''
}

{
	#category : ''Not categorized''
}
TonelMockD >> withoutCategory [

	"Created for tests"


]
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassInSubSubApp [

	self writer write: (TonelWriterClassDefinition of: TonelMockH definedIn: TonelWriterTestSubSubApp).
	self
		assertFileSystemIncludesFileAt: '/TonelMockH.class.st';
		assertContentsOfFileAt: '/TonelMockH.class.st'
			equals:
				'Class {
	#name : ''TonelMockH'',
	#superclass : ''Object'',
	#category : ''TonelWriterTestSubSubApp''
}
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassSubclassingNil [

	self writer write: (TonelWriterClassDefinition of: TonelMockE definedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/TonelMockE.class.st';
		assertContentsOfFileAt: '/TonelMockE.class.st'
			equals:
				'"
I exists just for testing purpose
"
Class {
	#name : ''TonelMockE'',
	#superclass : ''nil'',
	#category : ''TonelWriterTests''
}
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassWithByteSubclass [

	self writer write: (TonelWriterClassDefinition of: TonelBytesMock definedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/TonelBytesMock.class.st';
		assertContentsOfFileAt: '/TonelBytesMock.class.st'
			equals:
				'Class {
#name : ''TonelBytesMock'',
#superclass : ''ArrayedCollection'',
#type : ''bytes'',
#category : ''TonelWriterTests''
}
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassWithCIassAndClassInstanceVariables [

	self writer write: (TonelWriterClassDefinition of: TonelMockF definedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/TonelMockF.class.st';
		assertContentsOfFileAt: '/TonelMockF.class.st'
			equals:
				'Class {
	#name : ''TonelMockF'',
	#superclass : ''Object'',
	#classVars : [
		''ClassVar1''
	],
	#classInstVars : [
		''classInstVar1''
	],
	#category : ''TonelWriterTests''
}
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassWithComment [

	self writer write: (TonelWriterClassDefinition of: TonelMockA definedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/TonelMockA.class.st';
		assertContentsOfFileAt: '/TonelMockA.class.st'
			equals:
				'"
Class comment for tests
"
Class {
	#name : ''TonelMockA'',
	#superclass : ''Object'',
	#instVars : [
		''numerator'',
		''denominator''
	],
	#classVars : [
		''ClassVar''
	],
	#category : ''TonelWriterTests''
}

{
	#category : ''Accessing''
}
TonelMockA class >> classVar [

	ClassVar := 1
]

{
	#category : ''Testing''
}
TonelMockA class >> isTonelMock [

	^true
]

{
	#category : ''Accessing''
}
TonelMockA >> denominator [

	^denominator
]

{
	#category : ''Private'',
	#vaVisibility : ''private''
}
TonelMockA >> privateMethod [

	^''privateMethod''
]

{
	#category : ''Evaluating''
}
TonelMockA >> value [

	^numerator / denominator
]

{
	#category : ''Accessing''
}
TonelMockA >> withComment [
	"This is a mock method being used within the tests of Tonel"

	^''Method with comment''
]

{
	#category : ''Accessing''
}
TonelMockA >> withDenominatorDo: aDyadicBlock [

	^aDyadicBlock value: denominator
]

{
	#category : ''Accessing''
}
TonelMockA >> withLocalVariable [

	| localVariable |

	localVariable := ''tonel'' reverse.

	^localVariable
]

{
	#category : ''Accessing''
}
TonelMockA >> withModeThanOneLine [

	^(self value > 4) 
		ifTrue: [denominator / 2 ] 
		ifFalse: [numerator]
]

{
	#category : ''Accessing'',
	#vaCategories : [''Accessing'',''Evaluating'',''Private'']
}
TonelMockA >> withMultipleCategories [

	^ ''withMultipleCategories''
]
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassWithExtensionMethod [

	self writer write: (TonelWriterClassDefinition of: TonelMockA definedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/TonelMockA.class.st';
		assertContentsOfFileAt: '/TonelMockA.class.st'
			equals:
		'"
Class comment for tests
"
Class {
	#name : ''TonelMockA'',
	#superclass : ''Object'',
	#instVars : [
		''numerator'',
		''denominator''
	],
	#classVars : [
		''ClassVar''
	],
	#category : ''TonelWriterTests''
}

{
	#category : ''Accessing''
}
TonelMockA class >> classVar [

	ClassVar := 1
]

{
	#category : ''Testing''
}
TonelMockA class >> isTonelMock [

	^true
]

{
	#category : ''Accessing''
}
TonelMockA >> denominator [

	^denominator
]

{
	#category : ''Private'',
	#vaVisibility : ''private''
}
TonelMockA >> privateMethod [

	^''privateMethod''
]

{
	#category : ''Evaluating''
}
TonelMockA >> value [

	^numerator / denominator
]

{
	#category : ''Accessing''
}
TonelMockA >> withComment [
	"This is a mock method being used within the tests of Tonel"

	^''Method with comment''
]

{
	#category : ''Accessing''
}
TonelMockA >> withDenominatorDo: aDyadicBlock [

	^aDyadicBlock value: denominator
]

{
	#category : ''Accessing''
}
TonelMockA >> withLocalVariable [

	| localVariable |

	localVariable := ''tonel'' reverse.

	^localVariable
]

{
	#category : ''Accessing''
}
TonelMockA >> withModeThanOneLine [

	^(self value > 4) 
		ifTrue: [denominator / 2 ] 
		ifFalse: [numerator]
]

{
	#category : ''Accessing'',
	#vaCategories : [''Accessing'',''Evaluating'',''Private'']
}
TonelMockA >> withMultipleCategories [

	^ ''withMultipleCategories''
]
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassWithInstanceVariables [

	self writer write: (TonelWriterClassDefinition of: TonelMockC definedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/TonelMockC.class.st';
		assertContentsOfFileAt: '/TonelMockC.class.st'
			equals:
				'Class {
	#name : ''TonelMockC'',
	#superclass : ''Object'',
	#instVars : [
		''amount'',
		''unit''
	],
	#category : ''TonelWriterTests''
}
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassWithPoolDictionaryUsage [

	self writer write: (TonelWriterClassDefinition of: TonelMockG definedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/TonelMockG.class.st';
		assertContentsOfFileAt: '/TonelMockG.class.st'
			equals:
				'Class {
	#name : ''TonelMockG'',
	#superclass : ''Object'',
	#pools : [
		''CldtConstants''
	],
	#category : ''TonelWriterTests''
}

{
	#category : ''Not categorized''
}
TonelMockG >> methodWithPoolDictionaryUsage [

	^Cr
]
'
]

{ #category : 'Tests' }
TonelClassWriterTest >> testWriteClassWithVariableSubclass [

	self writer write: (TonelWriterClassDefinition of: TonelVariableMock definedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/TonelVariableMock.class.st';
		assertContentsOfFileAt: '/TonelVariableMock.class.st'
			equals:
				'Class {
#name : ''TonelVariableMock'',
#superclass : ''ArrayedCollection'',
#type : ''variable'',
#category : ''TonelWriterTests''
}
'
]
