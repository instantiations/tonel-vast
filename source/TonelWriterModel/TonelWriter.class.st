Class {
	#name : 'TonelWriter',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'lineDelimiter',
		'clearsSourcesDirectory',
		'applications',
		'configurationMaps',
		'autoLoad',
		'convertsSharedPools',
		'canonical',
		'flattenSubApplications',
		'writeENVYApps',
		'identifiersClass',
		'useMonticelloExtensions',
		'ignoresTonelPackageNameMethod'
	],
	#classVars : [
		'LineDelimiter'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'accessing' }
TonelWriter class >> classLabel [
	"Answers Tonel's class type label."

	^ 'Class'
]

{ #category : 'Defaults' }
TonelWriter class >> defaultLineDelimiter [

	^CldtConstants::LineDelimiter
]

{ #category : 'accessing' }
TonelWriter class >> extensionLabel [
	"Answers Tonel's class extension type label."

	^ 'Extension'
]

{ #category : 'accessing' }
TonelWriter class >> lineDelimiter [

	^LineDelimiter ifNil: [LineDelimiter := self defaultLineDelimiter]
]

{ #category : 'accessing' }
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

{ #category : 'accessing' }
TonelWriter class >> packageLabel [
	"Answers Tonel's Package type label."

	^ 'Package'
]

{ #category : 'configuring' }
TonelWriter >> addApplication: emApplication [

	^self applications add: emApplication
]

{ #category : 'configuring' }
TonelWriter >> addApplicationsFromConfigurationMaps [
	
	self configurationMaps do: 
			[:configMap | 
			configMap applicationNames do: 
					[:name | 
					| emApplication |
					emApplication := Smalltalk classAt: name asSymbol ifAbsent: [
						self error: ('<1p> is not loaded in the image.' expandMacrosWith: name)
					].
					(self applications includes: emApplication) 
						ifFalse: [self addApplication: emApplication]]]
]

{ #category : 'accessing' }
TonelWriter >> addConfigurationMap: anEmConfigurationMap [
	"Adds anEmConfigurationMap to receiver loading it first if autoLoad is true."

	self addConfigurationMap: anEmConfigurationMap force: false
]

{ #category : 'accessing' }
TonelWriter >> addConfigurationMap: anEmConfigurationMap force: aBoolean [
	"Adds anEmConfigurationMap to receiver loading it first if autoLoad is true.
	 Force addition if aBoolean is true."

	(self configurationMaps anySatisfy: [:each | each name = anEmConfigurationMap name])
		ifTrue: [
			self error: (
				'You can only add one Configuration Map for <1p>.'
					expandMacrosWith: anEmConfigurationMap name)].

	(anEmConfigurationMap isLoaded or: [aBoolean])
		ifFalse: [
			self autoLoad 
				ifTrue: [anEmConfigurationMap loadWithRequiredMaps]
				ifFalse: [
				self error: ('The config map <1p> must be loaded before exporting it to Tonel.'	expandMacrosWith: anEmConfigurationMap)
					]
		].

	self configurationMaps add: anEmConfigurationMap
]

{ #category : 'writing-ConfigMaps',
  #vaVisibility : 'private' }
TonelWriter >> addConfigurationMapData: aConfigurationMap into: aCollection [

	| aDictionary confExpressions conditions |

	aDictionary := self mapClass new.
	aDictionary
		at: #formatVersion put: '1.1';
		at: #name put: aConfigurationMap name;
		at: #versionName put: aConfigurationMap versionName;
		at: #ts put: aConfigurationMap timeStamp seconds;
		at: #applications
			put: (
				aConfigurationMap shadowApplications asSortedCollection collect: [:each |
					(self mapClass
						with: #name -> each name asString
						with: #versionName -> each versionName
						with: #ts -> each timeStamp seconds)]).
	conditions := aConfigurationMap requiredMapsConfigurations.
	confExpressions := OrderedCollection new.
	conditions do: [:condition | | dict |
		dict := self mapClass new.
		dict
			at: #condition put: condition key;
			at: #requiredMaps
				put:
					(condition value collect: [:each | | requiredMap |
						requiredMap := EmConfigurationMap named: each key timeStamp: each value.
						(self mapClass
							with: #name -> requiredMap name
							with: #versionName -> requiredMap versionName
							with: #ts -> each value seconds)])
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

{ #category : 'configuring' }
TonelWriter >> addConfigurationMaps: aCollection [

	aCollection do: [:each | self addConfigurationMap: each ]
]

{ #category : 'accessing' }
TonelWriter >> addLatestConfigurationMapNamed: configMapName [

	self addConfigurationMap: (EmConfigurationMap editionsFor: configMapName) first
		
]

{ #category : 'accessing' }
TonelWriter >> applications [
	^applications ifNil: [applications := OrderedCollection new]
]

{ #category : 'accessing' }
TonelWriter >> applications: anObject [
	applications := anObject
]

{ #category : 'accessing' }
TonelWriter >> autoLoad [
	"Answer whether receiver will load applications or config maps that are not loaded
	 before writing them in Tonel format."

	^autoLoad
]

{ #category : 'accessing' }
TonelWriter >> autoLoad: aBoolean [
	autoLoad := aBoolean
]

{ #category : 'configuring' }
TonelWriter >> beCanonical [
	"Sets the receiver settings to be 'canonical' as in compatible with other dialects.
	 without doing any conversion."
	
	self convertsSharedPools: true.
	self flattenSubApplications: true.
	self useMonticelloExtensions: true.
	self writeENVYApps: false.
	self ignoresTonelPackageNameMethod: false
]

{ #category : 'configuring' }
TonelWriter >> beVASTOnly [
	"Sets the receiver settings to target VAST as the target dialect for its output."
	
	self convertsSharedPools: false.
	self flattenSubApplications: false.
	self useMonticelloExtensions: false.
	self writeENVYApps: true.
	self ignoresTonelPackageNameMethod: true.
]

{ #category : 'utility' }
TonelWriter >> clearSourcesDirectory [

	self clearsSourcesDirectory: true
]

{ #category : 'accessing' }
TonelWriter >> clearsSourcesDirectory [
	"Answer whether receiver will delete the sources directory before 
	 writing Packages into it."
	 
	^clearsSourcesDirectory
]

{ #category : 'accessing' }
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

{ #category : 'utility' }
TonelWriter >> convertIdentifier: identifier [
	"Converts identifier <Symbol|String> according to receiver configuration."

	^String streamContents: [:s | | result |
		result :=
			self identifiersClass = Symbol
				ifTrue: [
					(identifier allSatisfy: [:char | char isAlphaNumeric])
						ifTrue: [identifier asSymbol]
						ifFalse: ['#' , identifier asString]]
				ifFalse: [identifier asString].
		(STONWriter on: s)
			nextPut: result;
			close]
]

{ #category : 'configuring' }
TonelWriter >> convertSharedPools [

 	self convertsSharedPools: true
]

{ #category : 'accessing' }
TonelWriter >> convertsSharedPools [
	^convertsSharedPools ifNil: [convertsSharedPools := true]
]

{ #category : 'accessing' }
TonelWriter >> convertsSharedPools: anObject [
	convertsSharedPools := anObject
]

{ #category : 'utility' }
TonelWriter >> dontClearSourcesDirectory [

	self clearsSourcesDirectory: false
]

{ #category : 'configuring' }
TonelWriter >> dontConvertSharedPools [

 	self convertsSharedPools: false
]

{ #category : 'utility',
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

{ #category : 'accessing' }
TonelWriter >> flattenSubApplications [
	^flattenSubApplications
]

{ #category : 'accessing' }
TonelWriter >> flattenSubApplications: anObject [
	flattenSubApplications := anObject
]

{ #category : 'accessing' }
TonelWriter >> identifiersClass [
	^identifiersClass ifNil: [String]
]

{ #category : 'accessing' }
TonelWriter >> identifiersClass: aClass [
	identifiersClass := aClass
]

{ #category : 'accessing' }
TonelWriter >> ignoresTonelPackageNameMethod [
	"Answers whether receiver ignores the _TONEL_packageName method (if defined)
	 to compute the package name."

	^ignoresTonelPackageNameMethod
]

{ #category : 'accessing' }
TonelWriter >> ignoresTonelPackageNameMethod: aBoolean [
	"Defines whether receiver will ignore the _TONEL_packageName method (if defined)
	 to compute the package name."

	ignoresTonelPackageNameMethod := aBoolean
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelWriter >> initializeOn: aFileSystem [
	"Private - Initializes receiver on aFileSystem."

	fileSystem := aFileSystem.
	lineDelimiter := self class lineDelimiter.
	clearsSourcesDirectory := true.
	autoLoad := true.
	convertsSharedPools := false.
	flattenSubApplications := false.
	writeENVYApps := true.
	ignoresTonelPackageNameMethod := false
]

{ #category : 'accessing' }
TonelWriter >> lineDelimiter [
	
	^lineDelimiter
]

{ #category : 'accessing' }
TonelWriter >> lineDelimiter: aString [
	"Sets the line delimiter of receiver to be aString.
	 Usually aString is CR, LF or CRLF."

	lineDelimiter := aString
]

{ #category : 'writing-ConfigMaps',
  #vaVisibility : 'private' }
TonelWriter >> mapClass [
	"Answer the class used to write maps (aka 'hashmaps') when exporting."

	^Dictionary
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> toJSONStringPretty: anObject [

	^String streamContents: 
			[:stream | 
			(STONWriter on: stream) 
				jsonMode: true;
				newLine: lineDelimiter;
				prettyPrint: true;
				nextPut: anObject]
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> toSTONStringPretty: anObject [

	^String streamContents: 
			[:stream | 
			(STONWriter on: stream) 
				newLine: lineDelimiter;
				prettyPrint: true;
				nextPut: anObject]
]

{ #category : 'configuring' }
TonelWriter >> useCrEOL [

	self lineDelimiter: Character cr asString


]

{ #category : 'configuring' }
TonelWriter >> useCrLfEOL [

	self lineDelimiter: Character cr asString, Character lf asString


]

{ #category : 'configuring' }
TonelWriter >> useLfEOL [

	self lineDelimiter: Character lf asString


]

{ #category : 'accessing' }
TonelWriter >> useMonticelloExtensions [
	"Answer whether receiver will write method extensions using 
	 Monticello extension method category, as in '*PackageName'."

	^useMonticelloExtensions ifNil: [useMonticelloExtensions := false]
]

{ #category : 'accessing' }
TonelWriter >> useMonticelloExtensions: aBoolean [
	"Sets whether receiver will write method extensions using 
	 Monticello extension method category, as in '*PackageName'."

	useMonticelloExtensions := aBoolean
]

{ #category : 'configuring' }
TonelWriter >> useSymbolIdentifiers [

	self identifiersClass: Symbol
]

{ #category : 'utility',
  #vaVisibility : 'private' }
TonelWriter >> withStreamOn: aFilePath do: aBlock [

	fileSystem
		createWriteStreamOn: aFilePath
		during: [:writeStream | aBlock value: (TonelUTF8StreamWriterWrapper wrapping: writeStream)]
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> writeApplication: anApplication into: aPath [
	"Private - Writes anApplication as package directory into aPath."

	self writeApplication: anApplication into: aPath rootApp: anApplication
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> writeApplication: anApplication into: aPath rootApp: rootApplication [
	"Private - Writes anApplication as package directory into aPath."

	| applicationDefinition packageDirectory isRootApp |

	isRootApp := anApplication = rootApplication.
	(self flattenSubApplications and: [anApplication isSubApplication])
		ifTrue: [applicationDefinition := TonelWriterSubApplicationDefinition for: anApplication]
		ifFalse: [
			applicationDefinition := TonelWriterApplicationDefinition for: anApplication.
			self ignoresTonelPackageNameMethod
				ifTrue: [applicationDefinition setPackageNameFromAppName]
			].

	packageDirectory :=
		self
			ensureDirectory: applicationDefinition tonelPackageName
			inside: aPath
			recreate: isRootApp.

	(isRootApp or: [self flattenSubApplications not])
		ifTrue: [self writePackageDescriptionFor: applicationDefinition into: packageDirectory].
	self convertsSharedPools
		ifTrue: [self writePoolDictionariesDefinedIn: applicationDefinition into: packageDirectory].
	self writeClassesDefinedIn: applicationDefinition into: packageDirectory.
	self writeClassesExtendedBy: applicationDefinition into: packageDirectory.
	applicationDefinition allPossibleDirectSubApplications do: [:aDirectSubApp |
		self writeApplication: aDirectSubApp into: aPath rootApp: rootApplication]
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> writeApplicationsInto: aPath [
	
	self applications do: [:application | self writeApplication: application into: aPath]
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> writeClassesDefinedIn: anApplicationDefinition into: aPath [

	"Private - Writes the class definition files of the classes
	defined by anApplicationDefinition into the the package directory <aPath>."

	| classWriter |
	classWriter := TonelClassWriter 
				on: fileSystem
				directory: aPath
				lineDelimiter: lineDelimiter
				in: self.
	anApplicationDefinition withDefinitionsOfDefinedClassesDo: 
			[:classDefinition | 
			(self writeENVYApps not and: 
					[#(#Application #SubApplication) 
						includes: classDefinition definedClassSuperclassName]) 
				ifFalse: [classWriter write: classDefinition]]
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> writeClassesExtendedBy: anApplicationDefinition into: aPath [

	"Private - Writes the class extensions files of the classes
	 extended by anApplicationDefinition into the the package directory <aPath>."

	| classExtensionWriter |
	classExtensionWriter := TonelClassExtensionWriter 
				on: fileSystem
				directory: aPath
				lineDelimiter: lineDelimiter
				in: self.
	anApplicationDefinition withDefinitionsOfExtendedClassesDo: 
			[:classDefinition | 
			classExtensionWriter write: classDefinition]
]

{ #category : 'writing-ConfigMaps',
  #vaVisibility : 'private' }
TonelWriter >> writeConfigurationMapsInto: aPath [

	self configurationMaps notEmpty
		ifTrue: [
			self
				withStreamOn: (aPath append: '.configmaps')
				do: [:writeStream | | data |
					data := OrderedCollection new.
					self configurationMaps
						do: [:each | self addConfigurationMapData: each into: data].
					writeStream nextPutAll: (self toSTONStringPretty: data asArray)]]
]

{ #category : 'accessing' }
TonelWriter >> writeENVYApps [
	^writeENVYApps
]

{ #category : 'accessing' }
TonelWriter >> writeENVYApps: anObject [
	writeENVYApps := anObject
]

{ #category : 'writing-project' }
TonelWriter >> writeInWorkingDirectory [

	^self writeProjectInto: (CfsPath named: CfsDirectoryDescriptor getcwd)
]

{ #category : 'writing-project' }
TonelWriter >> writeInWorkingDirectoryProjectIncluding: anApplicationSet [

	self applications: anApplicationSet.
	^self writeProjectInto: (CfsPath named: CfsDirectoryDescriptor getcwd)
]

{ #category : 'writing-application',
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
			self flattenSubApplications
				ifFalse: [
					self writePackageVAPrerequisitesOf: anApplicationDefinition on: stream.
					self writePackageVAParentOf: anApplicationDefinition on: stream.
					self writePackageVASubapplicationsOf: anApplicationDefinition on: stream].
			stream << lineDelimiter << '}' << lineDelimiter]
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageNameOf: anApplicationDefinition on: aStream [
	"Private - Writes the Tonel package name of anApplicationDefinition on aStream."

	aStream << Character tab << '#name : ' << (self convertIdentifier: anApplicationDefinition tonelPackageName)
		
		
		
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> writePackageVAParentOf: anApplicationDefinition on: aStream [
	"Private - Writes the #vaParent: application metadata on aStream."

	anApplicationDefinition hasDefaultParent
		ifFalse: [
			aStream << ',' << lineDelimiter << Character tab << '#vaParent : ' <<
				anApplicationDefinition definedApplication parent name asString printString]
]

{ #category : 'writing-application',
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

{ #category : 'writing-application',
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

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> writePoolDictionariesDefinedIn: applicationDefinition into: aPath [

	"Private - Writes the pool dictionaries defined by <applicationDefinition>
	 into aPath where the package contents are."

	| classWriter |
	classWriter := TonelSharedPoolWriter 
				on: fileSystem
				directory: aPath
				lineDelimiter: lineDelimiter
				in: self.
	applicationDefinition withPoolPragmaMethodsDo: 
			[:each | 
			self 
				writePoolDictionaryFromMethod: each
				definedIn: applicationDefinition
				using: classWriter]
]

{ #category : 'writing-application',
  #vaVisibility : 'private' }
TonelWriter >> writePoolDictionaryFromMethod: methodDefinition definedIn: applicationDefinition using: classWriter [
	"Private - Writes the pool dictionarie of <methodDefinition> defined in <applicationDefinition>
	 into aPath where the package contents are using the Tonel <classWriter>."

	| writerPoolDefinition |

	writerPoolDefinition :=
		TonelWriterSharedPoolDefinition declaredBy: methodDefinition definedIn: applicationDefinition.
	classWriter write: writerPoolDefinition
]

{ #category : 'writing-project' }
TonelWriter >> writeProjectInto: aPath [

	self 
		writeProjectInto: aPath
		sourceDirectoryName: 'source'
]

{ #category : 'writing-project' }
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

{ #category : 'writing-project',
  #vaVisibility : 'private' }
TonelWriter >> writeProjectPropertiesInto: aPath sourceDirectoryName: aString [
	| projectPropertiesPath |

	projectPropertiesPath := aPath append: '.project'.
	self
		withStreamOn: projectPropertiesPath
		do: [:stream | stream << '{' << lineDelimiter << ('#srcDirectory : ''', aString, '''') << lineDelimiter << '}']
]

{ #category : 'writing-project',
  #vaVisibility : 'private' }
TonelWriter >> writeSourcePropertiesInto: sourcePath [

	| projectPropertiesPath |

	projectPropertiesPath := sourcePath append: '.properties'.
	projectPropertiesPath exists
		ifFalse: [
			self
				withStreamOn: projectPropertiesPath
				do: [:stream |
					stream << '{' << lineDelimiter << '#format : ''tonel'',' << lineDelimiter << '#formatVersion: ''1.1''' << lineDelimiter << '}']]
]
