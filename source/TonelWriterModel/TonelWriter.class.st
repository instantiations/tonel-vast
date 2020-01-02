Class {
	#name : 'TonelWriter',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'lineDelimiter',
		'clearsSourcesDirectory'
	],
	#classVars : [
		'LineDelimiter'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Accessing' }
TonelWriter class >> classLabel [
	"Answers Tonel's class type label."

	^ 'Class'
]

{ #category : 'Defaults' }
TonelWriter class >> defaultLineDelimiter [

	^CldtConstants::LineDelimiter
]

{ #category : 'Accessing' }
TonelWriter class >> extensionLabel [
	"Answers Tonel's class extension type label."

	^ 'Extension'
]

{ #category : 'Accessing' }
TonelWriter class >> lineDelimiter [

	^LineDelimiter ifNil: [LineDelimiter := self defaultLineDelimiter]
]

{ #category : 'Instance Creation' }
TonelWriter class >> new [
	"Answer a new instance of receiver."

	^self on: TonelCfsFileSystem new
]

{ #category : 'Instance Creation' }
TonelWriter class >> on: aFileSystem [
	"Answer a new instance of receiver intialized on aFileSystem."

	^super new initializeOn: aFileSystem
]

{ #category : 'Accessing' }
TonelWriter class >> packageLabel [
	"Answers Tonel's Package type label."

	^ 'Package'
]

{ #category : 'Utility' }
TonelWriter >> clearSourcesDirectory [

	self clearsSourcesDirectory: true
]

{ #category : 'Accessing' }
TonelWriter >> clearsSourcesDirectory [
	"Answer whether receiver will delete the sources directory before 
	 writing Packages into it."
	 
	^clearsSourcesDirectory ifNil: [clearsSourcesDirectory := true]
]

{ #category : 'Accessing' }
TonelWriter >> clearsSourcesDirectory: aBoolean [
	"Sets whether receiver will delete the sources directory before writing Packages into it."
	 
	clearsSourcesDirectory := aBoolean
]

{ #category : 'Utility' }
TonelWriter >> dontClearSourcesDirectory [

	self clearsSourcesDirectory: false
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelWriter >> ensureDirectory: aString inside: aPath recreate: aBoolean [
	"Private - Ensures the existence of a directory named aString
	 within aPath, and delete all its contents if aBoolean is true and the 
	 directory exists."

	| path |

	path := aPath append: aString.
	(aBoolean and: [path exists]) ifTrue: [path deleteAll].
	path realize.
	^path
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelWriter >> initializeOn: aFileSystem [
	"Private - Initializes receiver on aFileSystem."

	fileSystem := aFileSystem.
	lineDelimiter := self class lineDelimiter.
	self clearSourcesDirectory.
]

{ #category : 'Accessing' }
TonelWriter >> lineDelimiter: aString [
	"Sets the line delimiter of receiver to be aString.
	 Usually aString is CR, LF or CRLF."

	lineDelimiter := aString
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
TonelWriter >> writeApplication: anApplication into: aPath [

	"Private - Writes anApplication as package directory into aPath."

	| applicationDefition packageDirectory |
	applicationDefition := TonelWriterApplicationDefinition for: anApplication.
	packageDirectory := self 
				ensureDirectory: applicationDefition tonelPackageName
				inside: aPath
				recreate: true.
	self writePackageDescriptionFor: applicationDefition into: packageDirectory.
	self writePoolDictionariesDefinedIn: applicationDefition
		into: packageDirectory.
	self writeClassesDefinedIn: applicationDefition into: packageDirectory.
	self writeClassesExtendedBy: applicationDefition into: packageDirectory.
	applicationDefition allPossibleDirectSubApplications 
		do: [:aDirectSubApp | self writeApplication: aDirectSubApp into: aPath]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writeApplications: aCollection into: aPath [
	"Private - Writes aCollection of <Application> into aPath."

	aCollection do: [:application | self writeApplication: application into: aPath]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writeClassesDefinedIn: anApplicationDefinition into: aPath [
	"Private - Writes the class definition files of the classes
	defined by anApplicationDefinition into the the package directory <aPath>."

	| classWriter |

	classWriter := TonelClassWriter writingOn: fileSystem into: aPath lineDelimiter: lineDelimiter.
	anApplicationDefinition
		withDefinitionsOfDefinedClassesDo: [:classDefinition | classWriter write: classDefinition]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writeClassesExtendedBy: anApplicationDefinition into: aPath [
	"Private - Writes the class extensions files of the classes
	 extended by anApplicationDefinition into the the package directory <aPath>."

	| classExtensionWriter |

	classExtensionWriter :=
		TonelClassExtensionWriter writingOn: fileSystem into: aPath lineDelimiter: lineDelimiter.
	anApplicationDefinition withDefinitionsOfExtendedClassesDo: [:classDefinition |
		classExtensionWriter write: classDefinition]
]

{ #category : 'Writing - Project' }
TonelWriter >> writeInWorkingDirectoryProjectIncluding: anApplicationSet [

	^self
		writeProjectIncluding: anApplicationSet
		into: (CfsPath named: CfsDirectoryDescriptor getcwd)
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageDescriptionFor: anApplicationDefinition into: aPath [
	"Private - Writes the package description file of anApplicationDefinition into 
	 the the package directory <aPath>."

	| packageDescriptionPath |

	packageDescriptionPath := aPath append: 'package.st'.
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
	"Private - Writes the Tonel package name of anApplicationDefinition on aStream."

	aStream << Character tab << '#name : ' << anApplicationDefinition tonelPackageName storeString 
		
		
		
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageVAParentOf: anApplicationDefinition on: aStream [
	"Private - Writes the #vaParent: application metadata on aStream."

	anApplicationDefinition hasDefaultParent
		ifFalse: [
			aStream << ',' << lineDelimiter << Character tab << '#vaParent : ' <<
				anApplicationDefinition definedApplication parent name asString printString]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageVAPrerequisitesOf: anApplicationDefinition on: aStream [
	"Private - Writes the #vaPrerequisites: metadata of anApplicationDefinition on aStream."

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
	"Private - Writes the #vaSubApplications: metadata of anApplicationDefinition on aStream."

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
TonelWriter >> writePoolDictionariesDefinedIn: applicationDefinition into: aPath [
	"Private - Writes the pool dictionaries defined by <applicationDefinition>
	 into aPath where the package contents are."

	| classWriter |

	classWriter :=
		TonelSharedPoolWriter writingOn: fileSystem into: aPath lineDelimiter: lineDelimiter.

	applicationDefinition withPoolPragmaMethodsDo: [:each |
		self writePoolDictionaryFromMethod: each definedIn: applicationDefinition using: classWriter]
]

{ #category : 'Writing - Application',
  #vaVisibility : 'private' }
TonelWriter >> writePoolDictionaryFromMethod: methodDefinition definedIn: applicationDefinition using: classWriter [
	"Private - Writes the pool dictionarie of <methodDefinition> defined in <applicationDefinition>
	 into aPath where the package contents are using the Tonel <classWriter>."

	| writerPoolDefinition |

	writerPoolDefinition :=
		TonelWriterSharedPoolDefinition declaredBy: methodDefinition definedIn: applicationDefinition.
	classWriter write: writerPoolDefinition
]

{ #category : 'Writing - Project' }
TonelWriter >> writeProjectIncluding: aCollectionOfApps into: aPath [

	self 
		writeProjectIncluding: aCollectionOfApps
		into: aPath
		sourceDirectoryName: 'source'
]

{ #category : 'Writing - Project' }
TonelWriter >> writeProjectIncluding: aCollection into: aPath sourceDirectoryName: aString [

	| sourcePath |
	aPath exists ifFalse: [aPath realize].
	self writeProjectPropertiesInto: aPath sourceDirectoryName: aString.
	sourcePath := self 
				ensureDirectory: aString
				inside: aPath
				recreate: self clearsSourcesDirectory.
	self writeSourcePropertiesInto: sourcePath.
	self writeApplications: aCollection into: sourcePath
]

{ #category : 'Writing - Project',
  #vaVisibility : 'private' }
TonelWriter >> writeProjectPropertiesInto: aPath sourceDirectoryName: aString [
	| projectPropertiesPath |

	projectPropertiesPath := aPath append: '.project'.
	self
		withStreamOn: projectPropertiesPath
		do: [:stream | stream << '{' << lineDelimiter << ('#srcDirectory : ''', aString, '''') << lineDelimiter << '}']
]

{ #category : 'Writing - Project',
  #vaVisibility : 'private' }
TonelWriter >> writeSourcePropertiesInto: sourcePath [

	| projectPropertiesPath |

	projectPropertiesPath := sourcePath append: '.properties'.
	projectPropertiesPath exists
		ifFalse: [
			self
				withStreamOn: projectPropertiesPath
				do: [:stream |
					stream << '{' << lineDelimiter << '#format : ''tonel''' << lineDelimiter << '}']]
]
