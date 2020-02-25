Class {
	#name : 'TonelWriter',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'lineDelimiter',
		'clearsSourcesDirectory',
		'applications',
		'configurationMaps'
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

{ #category : 'Accessing' }
TonelWriter class >> lineDelimiter: aString [

	LineDelimiter := aString
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

{ #category : 'Configuring' }
TonelWriter >> addApplicationsFromConfigurationMaps [
	"Enter the new method definition below and click 'Resume'."

	self configurationMaps do: [:configMap |
		configMap applicationNames do: [:name | | application |
			application := (Smalltalk at: name asSymbol).
			(self applications includes: application) ifFalse: [self applications add: application]]]
]

{ #category : 'accessing' }
TonelWriter >> addConfigurationMap: anEmConfigurationMap [

	(self configurationMaps anySatisfy: [:each | each name = anEmConfigurationMap name])
		ifTrue: [
			self error: (
				'You can only add one Configuration Map for <1p>.'
					expandMacrosWith: anEmConfigurationMap name)].

	self configurationMaps add: anEmConfigurationMap
]

{ #category : 'Writing-ConfigurationMaps',
  #vaVisibility : 'private' }
TonelWriter >> addConfigurationMapData: aConfigurationMap into: aCollection [

	| aDictionary confExpressions conditions |

	aDictionary := Dictionary new.
	aDictionary
		at: #name put: aConfigurationMap name;
		at: #versionName put: aConfigurationMap versionName;
		at: #applications
			put:
				((aConfigurationMap applicationEditions associations
					collect: [:assoc | assoc key -> assoc value versionName])
						asSortedCollection: [:a :b | a key <= b key])
							asArray.

	conditions := aConfigurationMap requiredMapsConfigurations.
	confExpressions := OrderedCollection new.
	conditions do: [:condition | | dict |
		dict := Dictionary new.
		dict
			at: #condition put: condition key;
			at: #requiredMaps
				put:
					(condition value collect: [:each | | requiredMap |
						requiredMap := (EmConfigurationMap shadowClass
							named: each key
							timeStamp: each value).
						requiredMap name -> requiredMap versionName])
							asArray.
		confExpressions add: dict].

	aDictionary at: #conditions put: confExpressions asArray.
	aDictionary at: #comment put: aConfigurationMap comment.

	aCollection add: aDictionary
]

{ #category : 'accessing' }
TonelWriter >> addConfigurationMapNamed: configMapName versionName: aString [

	((EmConfigurationMap editionsFor: configMapName) detect: [:one | one versionName = aString] ifNone: [])
		ifNil: [self error: ('Could not locate the configuration map <1s> <2s>' expandMacrosWith: configMapName with: aString)]
		ifNotNil:[:configMap | self addConfigurationMap: configMap ]
]

{ #category : 'accessing' }
TonelWriter >> applications [
	^applications ifNil: [applications := OrderedCollection new]
]

{ #category : 'accessing' }
TonelWriter >> applications: anObject [
	applications := anObject
]

{ #category : 'Utility' }
TonelWriter >> clearSourcesDirectory [

	self clearsSourcesDirectory: true
]

{ #category : 'Accessing' }
TonelWriter >> clearsSourcesDirectory [
	"Answer whether receiver will delete the sources directory before 
	 writing Packages into it."
	 
	^clearsSourcesDirectory
]

{ #category : 'Accessing' }
TonelWriter >> clearsSourcesDirectory: aBoolean [
	"Sets whether receiver will delete the sources directory before writing Packages into it."
	 
	clearsSourcesDirectory := aBoolean
]

{ #category : 'accessing' }
TonelWriter >> configurationMaps [
	^configurationMaps ifNil: [configurationMaps := OrderedCollection new]
]

{ #category : 'accessing' }
TonelWriter >> configurationMaps: anObject [
	configurationMaps := anObject
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
	clearsSourcesDirectory := true
]

{ #category : 'Accessing' }
TonelWriter >> lineDelimiter: aString [
	"Sets the line delimiter of receiver to be aString.
	 Usually aString is CR, LF or CRLF."

	lineDelimiter := aString
]

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelWriter >> toSTONStringPretty: anObject [

	^String streamContents: 
			[:stream | 
			(STONWriter on: stream) 
				newLine: lineDelimiter;
				prettyPrint: true;
				nextPut: anObject]
]

{ #category : 'Configuring' }
TonelWriter >> useCrEOL [

	self lineDelimiter: Character cr asString


]

{ #category : 'Configuring' }
TonelWriter >> useCrLfEOL [

	self lineDelimiter: Character cr asString, Character lf asString


]

{ #category : 'Configuring' }
TonelWriter >> useLfEOL [

	self lineDelimiter: Character lf asString


]

{ #category : 'Utility',
  #vaVisibility : 'private' }
TonelWriter >> withStreamOn: aFilePath do: aBlock [

	fileSystem
		createWriteStreamOn: aFilePath
		during: [:writeStream | aBlock value: (TonelUTF8StreamWriterWrapper wrapping: writeStream)]
]

{ #category : 'Writing-Application',
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

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelWriter >> writeApplicationsInto: aPath [
	
	self applications do: [:application | self writeApplication: application into: aPath]
]

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelWriter >> writeClassesDefinedIn: anApplicationDefinition into: aPath [
	"Private - Writes the class definition files of the classes
	defined by anApplicationDefinition into the the package directory <aPath>."

	| classWriter |

	classWriter := TonelClassWriter on: fileSystem directory: aPath lineDelimiter: lineDelimiter.
	anApplicationDefinition
		withDefinitionsOfDefinedClassesDo: [:classDefinition | classWriter write: classDefinition]
]

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelWriter >> writeClassesExtendedBy: anApplicationDefinition into: aPath [
	"Private - Writes the class extensions files of the classes
	 extended by anApplicationDefinition into the the package directory <aPath>."

	| classExtensionWriter |

	classExtensionWriter :=
		TonelClassExtensionWriter on: fileSystem directory: aPath lineDelimiter: lineDelimiter.
	anApplicationDefinition withDefinitionsOfExtendedClassesDo: [:classDefinition |
		classExtensionWriter write: classDefinition]
]

{ #category : 'Writing-ConfigurationMaps',
  #vaVisibility : 'private' }
TonelWriter >> writeConfigurationMapsInto: aPath [

	self
		withStreamOn: (aPath append: '.configmaps')
		do: [:writeStream | | data |
			data := OrderedCollection new.
			self configurationMaps do: [:each | self addConfigurationMapData: each into: data].
			writeStream nextPutAll: (self toSTONStringPretty: data asArray)]
]

{ #category : 'Writing-Project' }
TonelWriter >> writeInWorkingDirectory [

	^self writeProjectInto: (CfsPath named: CfsDirectoryDescriptor getcwd)
]

{ #category : 'Writing-Project' }
TonelWriter >> writeInWorkingDirectoryProjectIncluding: anApplicationSet [

	self applications: anApplicationSet.
	^self writeProjectInto: (CfsPath named: CfsDirectoryDescriptor getcwd)
]

{ #category : 'Writing-Application',
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

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageNameOf: anApplicationDefinition on: aStream [
	"Private - Writes the Tonel package name of anApplicationDefinition on aStream."

	aStream << Character tab << '#name : ' << anApplicationDefinition tonelPackageName storeString 
		
		
		
]

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageVAParentOf: anApplicationDefinition on: aStream [
	"Private - Writes the #vaParent: application metadata on aStream."

	anApplicationDefinition hasDefaultParent
		ifFalse: [
			aStream << ',' << lineDelimiter << Character tab << '#vaParent : ' <<
				anApplicationDefinition definedApplication parent name asString printString]
]

{ #category : 'Writing-Application',
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

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageVASubapplicationsOf: anApplicationDefinition on: aStream [

	"Private - Writes the #vaSubApplications: metadata of anApplicationDefinition on aStream."

	| confExpressions application json |
	confExpressions := OrderedCollection new.
	application := anApplicationDefinition definedApplication.
	anApplicationDefinition hasDefaultSubApps 
		ifFalse: 
			[aStream << ',' << lineDelimiter << Character tab 
				<< '#vaSubApplications : '.
			application allConfigurationExpressions do: 
					[:each | 
					| dict |
					dict := Dictionary new.
					dict
						at: #condition put: each;
						at: #subapps
							put: ((application releasedSubApplicationsFor: each) keys sorted 
									collect: [:each2 | each2 asString]).
					confExpressions add: dict].
			confExpressions := confExpressions asArray.
	
			json := self toSTONStringPretty: confExpressions.
			aStream nextPutAll: json]
]

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelWriter >> writePoolDictionariesDefinedIn: applicationDefinition into: aPath [
	"Private - Writes the pool dictionaries defined by <applicationDefinition>
	 into aPath where the package contents are."

	| classWriter |

	classWriter := TonelSharedPoolWriter on: fileSystem directory: aPath lineDelimiter: lineDelimiter.

	applicationDefinition withPoolPragmaMethodsDo: [:each |
		self writePoolDictionaryFromMethod: each definedIn: applicationDefinition using: classWriter]
]

{ #category : 'Writing-Application',
  #vaVisibility : 'private' }
TonelWriter >> writePoolDictionaryFromMethod: methodDefinition definedIn: applicationDefinition using: classWriter [
	"Private - Writes the pool dictionarie of <methodDefinition> defined in <applicationDefinition>
	 into aPath where the package contents are using the Tonel <classWriter>."

	| writerPoolDefinition |

	writerPoolDefinition :=
		TonelWriterSharedPoolDefinition declaredBy: methodDefinition definedIn: applicationDefinition.
	classWriter write: writerPoolDefinition
]

{ #category : 'Writing-Project' }
TonelWriter >> writeProjectInto: aPath [

	self 
		writeProjectInto: aPath
		sourceDirectoryName: 'source'
]

{ #category : 'Writing-Project' }
TonelWriter >> writeProjectInto: aPath sourceDirectoryName: aString [

	| sourcePath |
	aPath exists ifFalse: [aPath realize].
	self writeProjectPropertiesInto: aPath sourceDirectoryName: aString.
	sourcePath := self 
				ensureDirectory: aString
				inside: aPath
				recreate: self clearsSourcesDirectory.
	self writeSourcePropertiesInto: sourcePath.
	self writeApplicationsInto: sourcePath.
	self writeConfigurationMapsInto: sourcePath
]

{ #category : 'Writing-Project',
  #vaVisibility : 'private' }
TonelWriter >> writeProjectPropertiesInto: aPath sourceDirectoryName: aString [
	| projectPropertiesPath |

	projectPropertiesPath := aPath append: '.project'.
	self
		withStreamOn: projectPropertiesPath
		do: [:stream | stream << '{' << lineDelimiter << ('#srcDirectory : ''', aString, '''') << lineDelimiter << '}']
]

{ #category : 'Writing-Project',
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
