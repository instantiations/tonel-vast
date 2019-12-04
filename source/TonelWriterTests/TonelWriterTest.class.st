Class {
	#name : 'TonelWriterTest',
	#superclass : 'TonelMethodWriterTest',
	#category : 'TonelWriterTests'
}

{ #category : 'Tests - Support' }
TonelWriterTest >> assertTonelWriterModel [

	self
		assertFileSystemIncludesFileAt: '\TonelWriterModel\package.st';
		assertContentsOfFileAt: '\TonelWriterModel\package.st'
			equals:
				'Package {
	#name : ''TonelWriterModel'',
	#vaPrerequisites : [''EmLibraryInterface'',''STONVASTCoreApp'',''TonelFileSystem'']
}
';
		assertFileSystemIncludesFileAt: '\TonelWriterModel\TonelWriterApplicationDefinition.class.st';
		assertFileSystemIncludesFileAt: '\TonelWriterModel\TonelWriterClassDefinition.class.st';
		assertFileSystemIncludesFileAt:
			'\TonelWriterModel\TonelWriterClassExtensionDefinition.class.st';
		assertFileSystemIncludesFileAt: '\TonelWriterModel\TonelClassExtensionWriter.class.st';
		assertFileSystemIncludesFileAt: '\TonelWriterModel\TonelClassWriter.class.st';
		assertFileSystemIncludesFileAt: '\TonelWriterModel\TonelWriterMethodDefinition.class.st';
		assertFileSystemIncludesFileAt: '\TonelWriterModel\TonelMethodWriter.class.st';
		assertFileSystemIncludesFileAt: '\TonelWriterModel\TonelWriter.class.st';
		assertFileSystemIncludesFileAt: '\TonelWriterModel\TonelWriterModel.class.st';
		deny: (self fileSystem files includesKey: '\TonelWriterModel\TonelWriter.extension.st')
]

{ #category : 'Tests - Support' }
TonelWriterTest >> assertTonelWriterModelOnPath: aPath [

	self
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterModel/package.st';
		assertContentsOfFileAt: aPath , '/TonelWriterModel/package.st'
			equals:
			'Package {
	#name : ''TonelWriterModel'',
	#vaPrerequisites : [''EmClassDevelopment'',''STONVASTCoreApp'',''TonelFileSystem'']
}
';
		assertFileSystemIncludesFileAt:
			aPath , '/TonelWriterModel/TonelWriterApplicationDefinition.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterModel/TonelWriterClassDefinition.class.st';
		assertFileSystemIncludesFileAt:
			aPath , '/TonelWriterModel/TonelWriterClassExtensionDefinition.class.st';
		assertFileSystemIncludesFileAt:
			aPath , '/TonelWriterModel/TonelClassExtensionWriter.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterModel/TonelClassWriter.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterModel/TonelWriterMethodDefinition.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterModel/TonelMethodWriter.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterModel/TonelWriter.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterModel/TonelWriterModel.class.st';
		deny: (self fileSystem includes: aPath , '/TonelWriterModel/TonelWriter.extension.st')
]

{ #category : 'Tests - Support' }
TonelWriterTest >> assertTonelWriterTestOnPath: aPath [

	self
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/Object.extension.st';
		assertContentsOfFileAt: aPath , '/TonelWriterTests/package.st'
			equals:
				'Package {
	#name : ''TonelWriterTests'',
	#vaPrerequisites : [''SUnit'',''TonelWriterModel''],
	#vaSubApplications : [
	{
		#condition : ''true'',
		#subapps : [
			''TonelSubapplication''
		]
	}
]
}
';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelClassWriterTest.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelMethodWriterTest.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelMockA.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelMockB.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelMockC.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelMockE.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelMockF.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelMockG.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelWriter.extension.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelWriterTest.class.st';
		assertFileSystemIncludesFileAt: aPath , '/TonelWriterTests/TonelWriterTests.class.st';

		assertContentsOfFileAt: aPath , '/TonelSubapplication/package.st'
			equals:
			'Package {
	#name : ''TonelSubapplication'',
	#vaParent:  ''TonelWriterTests'',
	#vaSubApplications : [
	{
		#condition : ''(Smalltalk at: #\''TonelExampleConfExp\'' ifAbsentPut: [true] ) == false'',
		#subapps : [
			''TonelWriterTestShadowSubSubApp''
		]
	},
	{
		#condition : ''true'',
		#subapps : [
			''TonelWriterTestSubSubApp''
		]
	}
]
}
';
		assertFileSystemIncludesFileAt:
			aPath , '/TonelSubapplication/TonelMockD.class.st';
		assertFileSystemIncludesFileAt:
			aPath , '/TonelSubapplication/TonelSubapplication.class.st';
		assertFileSystemIncludesFileAt:
			aPath , '/TonelSubapplication/Object.extension.st';
		assertFileSystemIncludesFileAt:
			aPath , '/TonelSubapplication/TonelMockA.extension.st';


		assertFileSystemIncludesFileAt:
			aPath ,
				'/TonelWriterTestSubSubApp/TonelMockH.class.st';
		assertFileSystemIncludesFileAt:
			aPath ,
				'/TonelWriterTestSubSubApp/TonelWriterTestSubSubApp.class.st';
		assertFileSystemIncludesFileAt:
			aPath ,
				'/TonelWriterTestSubSubApp/Object.extension.st';
		assertContentsOfFileAt:
				aPath , '/TonelWriterTestSubSubApp/package.st'
			equals:
				'Package {
	#name : ''TonelWriterTestSubSubApp'',
	#vaParent:  ''TonelSubapplication''
}
';


		assertFileSystemIncludesFileAt:
			aPath ,
				'/TonelWriterTestShadowSubSubApp/TonelShadowMockJ.class.st';
		assertFileSystemIncludesFileAt:
			aPath ,
				'/TonelWriterTestShadowSubSubApp/TonelWriterTestShadowSubSubApp.class.st';
		assertFileSystemIncludesFileAt:
			aPath ,
				'/TonelWriterTestShadowSubSubApp/Object.extension.st';
		assertContentsOfFileAt:
				aPath ,
					'/TonelWriterTestShadowSubSubApp/package.st'
			equals:
				'Package {
	#name : ''TonelWriterTestShadowSubSubApp'',
	#vaParent : ''TonelSubapplication'',
	#vaSubApplications : [
	{
		#condition : ''true'',
		#subapps : [
			''TonelWriterTestShadowSubSubSubApp''
		]
	}
]
}
';


		assertFileSystemIncludesFileAt:
			aPath ,
				'/TonelWriterTestShadowSubSubSubApp/TonelShadowMockK.class.st';
		assertFileSystemIncludesFileAt:
			aPath ,
				'/TonelWriterTestShadowSubSubSubApp/TonelWriterTestShadowSubSubSubApp.class.st';
		assertFileSystemIncludesFileAt:
			aPath ,
				'/TonelWriterTestShadowSubSubSubApp/Object.extension.st';
		assertContentsOfFileAt:
				aPath ,
					'/TonelWriterTestShadowSubSubSubApp/package.st'
			equals:
				'Package {
	#name : ''TonelWriterTestShadowSubSubSubApp'',
	#vaParent : ''TonelWriterTestShadowSubSubApp''
}
'.



	self deny: (self fileSystem includes: aPath , '/TonelWriterTests/TonelWriter.class.st')
]

{ #category : 'Initialization' }
TonelWriterTest >> setUp [

	super setUp.
	self writer: (TonelWriter on: self fileSystem)
]

{ #category : 'Tests' }
TonelWriterTest >> testShadowApplications [

	self writer writeApplication: TonelWriterTests into: self directoryForTestingPath.
	
	self assertContentsOfFileAt:
				'/TonelWriterTestShadowSubSubApp/TonelShadowMockJ.class.st'
			equals:
				'Class {
	#name : ''TonelShadowMockJ'',
	#superclass : ''Object'',
	#instVars : [
		''instVar1''
	],
	#classVars : [
		''ClassVar1''
	],
	#pools : [
		''CldtConstants''
	],
	#classInstVars : [
		''classInstVar1''
	],
	#category : ''TonelWriterTestShadowSubSubApp''
}

{
	#category : ''Not categorized''
}
TonelShadowMockJ >> shadowMethodForTest [

	^''Shadow Method for testing TonelWriter''
]
';

	 assertContentsOfFileAt:
				'/TonelWriterTestShadowSubSubApp/Object.extension.st'
			equals:
				'Extension {
	#name : ''Object''
}

{ #category : ''*TonelWriterTestShadowSubSubApp'',
  #vaCategories : [''Not categorized''] }
Object >> shadowSubSubExtensionForTest [

	^''shadow sub sub Method extension for testing TonelWriter''
]
'.
]

{ #category : 'Tests' }
TonelWriterTest >> testShadowSubApplications [

	self writer writeApplication: TonelWriterTests into: self directoryForTestingPath.
	
	self assertContentsOfFileAt:
				'/TonelWriterTestShadowSubSubSubApp/TonelShadowMockK.class.st'
			equals:
				'Class {
	#name : ''TonelShadowMockK'',
	#superclass : ''Object'',
	#instVars : [
		''instVar1''
	],
	#classVars : [
		''ClassVar1''
	],
	#pools : [
		''CldtConstants''
	],
	#classInstVars : [
		''classInstVar1''
	],
	#category : ''TonelWriterTestShadowSubSubSubApp''
}

{
	#category : ''Not categorized''
}
TonelShadowMockK >> shadowSubMethodForTest [

	^''Shadow sub method for testing TonelWriter''
]
';

	 assertContentsOfFileAt:
				'/TonelWriterTestShadowSubSubSubApp/Object.extension.st'
			equals:
				'Extension {
	#name : ''Object''
}

{
	#category : ''*TonelWriterTestShadowSubSubSubApp'',
	#vaCategories : [''Not categorized'']
}
Object >> shadowSubSubSubExtensionForTest [

	^''shadow sub sub sub Method extension for testing TonelWriter''
]
'.
]

{ #category : 'Tests' }
TonelWriterTest >> testWriteApplication [

	self writer writeApplication: TonelWriterModel into: self directoryForTestingPath.
	self assertTonelWriterModelOnPath: ''.

]

{ #category : 'Tests' }
TonelWriterTest >> testWriteApplicationWithExtensionsSubappsAndShadows [

	self writer writeApplication: TonelWriterTests into: self directoryForTestingPath.
	self assertTonelWriterTestOnPath: ''.
]

{ #category : 'Tests' }
TonelWriterTest >> testWriteProject [

	self writer
		writeProjectIncluding: (Array with: TonelWriterTests with: TonelWriterModel)
		into: self directoryForTestingPath.
	self assertTonelWriterModelOnPath:  '/source'.
	self assertTonelWriterTestOnPath:  '/source'
]
