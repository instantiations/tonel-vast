Class {
	#name : 'TonelWriter',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'lineDelimiter'
	],
	#classVars : [
		'LineDelimiter'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Accessing' }
TonelWriter class >> classLabel [
	^ 'Class'
]

{ #category : 'Defaults' }
TonelWriter class >> defaultLineDelimiter [

	^CldtConstants::LineDelimiter
]

{ #category : 'Accessing' }
TonelWriter class >> extensionLabel [
	^ 'Extension'
]

{ #category : 'Accessing' }
TonelWriter class >> lineDelimiter [

	^LineDelimiter ifNil: [LineDelimiter := self defaultLineDelimiter]
]

{ #category : 'Instance Creation' }
TonelWriter class >> new [

	^self on: TonelCfsFileSystem new
]

{ #category : 'Instance Creation' }
TonelWriter class >> on: aFileSystem [

	^super new initializeOn: aFileSystem
]

{ #category : 'Accessing' }
TonelWriter class >> packageLabel [
	^ 'Package'
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelWriter >> createDirectoryNamed: aName inside: aDirectory [

	| path |

	path := aDirectory append: aName.
	path exists ifTrue: [path deleteAll].
	path realize.
	^path
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelWriter >> initializeOn: aFileSystem [

	fileSystem := aFileSystem.
	lineDelimiter := self class lineDelimiter
]

{ #category : 'Accessing' }
TonelWriter >> lineDelimiter: anObject [

	lineDelimiter := anObject
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelWriter >> withStreamOn: aFilePath do: aBlock [

	fileSystem
		createWriteStreamOn: aFilePath
		during: [:writeStream | aBlock value: (TonelUTF8StreamWriterWrapper wrapping: writeStream)]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writeApplication: anApplication into: sourceDirectory [

	| applicationDefition packageDirectory |

	applicationDefition := TonelWriterApplicationDefinition for: anApplication.

	packageDirectory :=
		self createDirectoryNamed: applicationDefition tonelPackageName inside: sourceDirectory.
	self writePackageDescriptionFor: applicationDefition into: packageDirectory.
	
	self writePoolDictionariesDefinedIn: applicationDefition into: packageDirectory.
	self writeClassesDefinedIn: applicationDefition into: packageDirectory.
	self writeMethodExtensions: applicationDefition into: packageDirectory.

	applicationDefition allPossibleDirectSubApplications
		do: [:aDirectSubApp | self writeApplication: aDirectSubApp into: sourceDirectory]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writeApplications: anApplicationSet into: sourcePath [

	anApplicationSet do: [:application | self writeApplication: application into: sourcePath]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writeClassesDefinedIn: anApplicationDefinition into: aPackageDirectory [

	| classWriter |

	classWriter :=
		TonelClassWriter writingOn: fileSystem into: aPackageDirectory lineDelimiter: lineDelimiter.

	anApplicationDefinition
		withDefinitionsOfDefinedClassesDo: [:classDefinition | classWriter write: classDefinition]
]

{ #category : 'Writing - Project' }
TonelWriter >> writeInWorkingDirectoryProjectIncluding: anApplicationSet [

	^self
		writeProjectIncluding: anApplicationSet
		into: (CfsPath named: CfsDirectoryDescriptor getcwd)
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writeMethodExtensions: anApplicationDefinition into: aPackageDirectory [

	| classExtensionWriter |

	classExtensionWriter :=
		TonelClassExtensionWriter
			writingOn: fileSystem
			into: aPackageDirectory
			lineDelimiter: lineDelimiter.
 
	anApplicationDefinition withDefinitionsOfExtendedClassesDo: [:classDefinition |
		classExtensionWriter write: classDefinition].

]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageDescriptionFor: anApplicationDefinition into: aWindowsRelativeFilePath [

	| packageDescriptionPath |

	packageDescriptionPath := aWindowsRelativeFilePath append: 'package.st'.

	self
		withStreamOn: packageDescriptionPath
		do: [:stream |
			stream << 'Package {' << lineDelimiter.
			self writePackageNameOf: anApplicationDefinition on: stream.	
			self writePackageVAPrerequisitesOf: anApplicationDefinition on: stream.
			self writePackageVAParentOf: anApplicationDefinition on: stream.
			self writePackageVASubapplicationsOf: anApplicationDefinition on: stream.
			stream << lineDelimiter << '}' << lineDelimiter]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageNameOf: anApplicationDefinition on: aStream [

	aStream << Character tab << '#name : ' << anApplicationDefinition tonelPackageName storeString 
		
		
		
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageVAParentOf: anApplicationDefinition on: stream [


	anApplicationDefinition hasDefaultParent
		ifFalse: [
			stream << ',' << lineDelimiter << Character tab << '#vaParent : ' <<
				anApplicationDefinition definedApplication parent name asString printString]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageVAPrerequisitesOf: anApplicationDefinition on: aStream [

	(anApplicationDefinition definedApplication isApplication
		and: [anApplicationDefinition hasDefaultPrerequisites not])
			ifTrue: [| prereqs |
				prereqs := anApplicationDefinition definedApplication prerequisiteNames.
				aStream << ',' << lineDelimiter << Character tab << '#vaPrerequisites : ' << '['.
				prereqs
					do: [:each | aStream nextPutAll: each asString printString]
					separatedBy: [aStream nextPut: $,].
				aStream nextPut: $]]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageVASubapplicationsOf: anApplicationDefinition on: aStream [

	| confExpressions application json |

	confExpressions := OrderedCollection new.
	application := anApplicationDefinition definedApplication.
	anApplicationDefinition hasDefaultSubApps
		ifFalse: [
			aStream << ',' << lineDelimiter << Character tab << '#vaSubApplications : '.
			application allConfigurationExpressions do: [:each | | dict |
				dict := Dictionary new.
				dict
					at: #condition put: each;
					at: #subapps
						put: (
							(application releasedSubApplicationsFor: each) keys sorted
								collect: [:each2 | each2 asString]).
				confExpressions add: dict].
			confExpressions := confExpressions asArray.
			json := STON toStringPretty: confExpressions.
			aStream nextPutAll: json]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePoolDictionariesDefinedIn: applicationDefinition into: packageDirectory [

	| classWriter |

	classWriter :=
		TonelSharedPoolWriter writingOn: fileSystem into: packageDirectory lineDelimiter: lineDelimiter.

	applicationDefinition withPoolPragmaMethodsDo: [:each |
		self writePoolDictionaryFromMethod: each definedIn: applicationDefinition using: classWriter]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePoolDictionaryFromMethod: methodDefinition definedIn: applicationDefinition using: classWriter [

	| writerPoolDefinition |
	writerPoolDefinition := TonelWriterSharedPoolDefinition declaredBy: methodDefinition definedIn: applicationDefinition.
	classWriter write: writerPoolDefinition
]

{ #category : 'Writing - Project' }
TonelWriter >> writeProjectIncluding: aCollectionOfApps into: aPath [

	self writeProjectIncluding: aCollectionOfApps sourceDirectoryNamed: 'source' into: aPath
]

{ #category : 'Writing - Project' }
TonelWriter >> writeProjectIncluding: aCollectionOfApps sourceDirectoryNamed: aSourceDirectoryName into: aPath [

	| sourcePath |

	aPath exists ifFalse: [aPath realize].
	self writeProjectPropertiesInto: aPath sourceDirectoryNamed: aSourceDirectoryName.
	sourcePath := self createDirectoryNamed: aSourceDirectoryName inside: aPath.
	self writeSourcePropertiesInto: sourcePath.
	self writeApplications: aCollectionOfApps into: sourcePath
]

{ #category : 'Writing - Project',
  #vaVisibility : 'private' }
TonelWriter >> writeProjectPropertiesInto: aRootDirPath sourceDirectoryNamed: aSourceDirectoryName [
	| projectPropertiesPath |

	projectPropertiesPath := aRootDirPath append: '.project'.
	self
		withStreamOn: projectPropertiesPath
		do: [:stream | stream << '{' << lineDelimiter << ('#srcDirectory : ''', aSourceDirectoryName, '''') << lineDelimiter << '}']
]

{ #category : 'Writing - Project',
  #vaVisibility : 'private' }
TonelWriter >> writeSourcePropertiesInto: sourcePath [

	| projectPropertiesPath |

	projectPropertiesPath := sourcePath append: '.properties'.
	self
		withStreamOn: projectPropertiesPath
		do: [:stream | stream << '{' << lineDelimiter << '#format : ''tonel''' << lineDelimiter << '}']
]
