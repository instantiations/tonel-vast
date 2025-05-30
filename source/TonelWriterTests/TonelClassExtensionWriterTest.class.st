Class {
	#name : 'TonelClassExtensionWriterTest',
	#superclass : 'TonelBaseTest',
	#category : 'TonelWriterTests'
}

{ #category : 'Not categorized' }
TonelClassExtensionWriterTest >> setUp [

	super setUp.
	writer :=
		TonelClassExtensionWriter
			on: fileSystem
			directory: self directoryForTestingPath
			lineDelimiter: TonelWriter lineDelimiter
			in: (
				TonelWriter new
					useMonticelloExtensions: true;
					yourself)
]

{ #category : 'Test' }
TonelClassExtensionWriterTest >> testWriteClassExtension [

	writer write: (TonelWriterClassExtensionDefinition of: TonelWriter extendedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt:  '/TonelWriter.extension.st';
		assertContentsOfFileAt:  '/TonelWriter.extension.st'
			equals:
				'Extension {
	#name : ''TonelWriter''
}

{
	#category : ''*TonelWriterTests'',
	#vaCategories : [''accessing'']
}
TonelWriter >> anotherExtensionForTest [

	^''Another method extension for testing TonelWriter''
]

{
	#category : ''*TonelWriterTests'',
	#vaCategories : [''accessing'']
}
TonelWriter >> extensionForTest [

	^''Methods extension for testing TonelWriter''
]
'
]

{ #category : 'Test' }
TonelClassExtensionWriterTest >> testWriteClassExtensionWithOtherExtensions [
	writer write: (TonelWriterClassExtensionDefinition of: Object extendedIn: TonelWriterTests).
	self
		assertFileSystemIncludesFileAt: '/Object.extension.st';
		assertContentsOfFileAt: '/Object.extension.st'
			equals:
				'Extension {
	#name : ''Object''
}

{
	#category : ''*TonelWriterTests'',
	#vaCategories : [''Not categorized'']
}
Object >> extensionForTest [

	^''Method extension for testing TonelWriter''
]

{
	#category : ''*TonelWriterTests'',
	#vaCategories : [''Not categorized''],
	#vaVisibility : ''private''
}
Object >> privateExtensionForTest [

	^''Private Method extension for testing TonelWriter''
]
'
]
