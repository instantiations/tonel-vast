Class {
	#name : 'TonelReader',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'sourceProperties',
		'packages',
		'configurationMaps',
		'repositoryPath'
	],
	#category : 'TonelReaderModel'
}

{ #category : 'Instance Creation' }
TonelReader class >> new [

	^self on: TonelCfsFileSystem new
	
]

{ #category : 'Instance Creation' }
TonelReader class >> on: aFileSystem [

	^super new initializeOn: aFileSystem
	
]

{ #category : 'Reading-Project',
  #vaVisibility : 'private' }
TonelReader >> addContentFrom: filePath toPackage: aPackageDefinition [
	"Private - Adds all the Tonel contents within filePath
	 to aPackageDefinition."

	filePath readUtf8StreamDo: [:aStream | | result |
		result := TonelParser parseStream: aStream.
		result first
			addToPackage: aPackageDefinition
			withAll:
				(result size > 1 ifTrue: [result copyFrom: 2 to: result size] ifFalse: [Array new])]
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelReader >> addPackage: aPackageDefinition [

	"Private - Adds aPackageDefinition to the collection of receiver's packages."

	^self packages add: aPackageDefinition
]

{ #category : 'Reading-Project',
  #vaVisibility : 'private' }
TonelReader >> computeSourcesDirectoryFrom: aPath [
	"Private - Answers the source directory computed from aPath, 
	 if none is found then returns aPath as the sources directory."

	^(self readSourceDirectoryNameFrom: aPath) ifNil: [aPath] ifNotNil: [:dir | aPath append: dir]
]

{ #category : 'Reading' }
TonelReader >> configMapsFilename [
	^'.configmaps'
]

{ #category : 'Accessing' }
TonelReader >> configurationMaps [

	^configurationMaps ifNil: [configurationMaps := OrderedCollection new]
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelReader >> includePackage: aPackageDefinition [

	"Private - If the receiver doesn't include aPackageDefinition
	 then add it to its list of packages. 
	 In either case, answers aPackageDefinition."

	^(self lookupPackage: aPackageDefinition ifNone: [self addPackage: aPackageDefinition]) 
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelReader >> initializeOn: aFileSystem [
	"Private - Initializes receiver on aFileSystem."

	fileSystem := aFileSystem.
	
	
]

{ #category : 'Package-Lookup',
  #vaVisibility : 'private' }
TonelReader >> lookupPackage: aPackageDefinition ifNone: aBlock [

	^self lookupPackageNamed: aPackageDefinition name ifNone: aBlock
]

{ #category : 'Package-Lookup',
  #vaVisibility : 'private' }
TonelReader >> lookupPackageNamed: aString [

	^self packages detect: [:each | each name = aString] ifNone: [self packages errorNotFound]
]

{ #category : 'Package-Lookup',
  #vaVisibility : 'private' }
TonelReader >> lookupPackageNamed: aString ifNone: aBlock [

	^self packages detect: [:each | each name = aString] ifNone: aBlock
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelReader >> packages [

	^packages ifNil: [	packages := OrderedCollection new]
]

{ #category : 'Reading',
  #vaVisibility : 'private' }
TonelReader >> readConfigurationMapsFrom: sourceDirPath [

	configurationMaps :=
		(sourceDirPath append: self configMapsFilename) exists
			ifTrue: [
				(STONReader on: (
					CfsReadFileStream open: (sourceDirPath append: self configMapsFilename) asString))
						next]
			ifFalse: [OrderedCollection new]
]

{ #category : 'Reading' }
TonelReader >> readFrom: aPath [

	| sourcesPath |
	repositoryPath := aPath.
	sourcesPath := self computeSourcesDirectoryFrom: aPath.
	self readPackages: nil from: sourcesPath.
	self readConfigurationMapsFrom: sourcesPath.
]

{ #category : 'Reading',
  #vaVisibility : 'private' }
TonelReader >> readPackageDirectories: aCollection [

	aCollection do: [:each | self readPackageFrom: each]
]

{ #category : 'Reading',
  #vaVisibility : 'private' }
TonelReader >> readPackageFileFrom: packageDirectory [

	| package |
	fileSystem
		createReadStreamOn: (packageDirectory append: 'package.st') asString
		during: [:stream | package := self includePackage: (TonelParser parseStream: stream) first].
	^package
	





]

{ #category : 'Reading',
  #vaVisibility : 'private' }
TonelReader >> readPackageFrom: packageDirectory [

	| package |
	package := self readPackageFileFrom: packageDirectory.
	(packageDirectory filesMatching: '*.st') do: 
			[:aFilename | 
			| filePath |
			aFilename = 'package.st' 
				ifFalse: 
					[filePath := packageDirectory append: aFilename.
					self addContentFrom: filePath toPackage: package]]
]

{ #category : 'Reading',
  #vaVisibility : 'private' }
TonelReader >> readPackages: aCollection from: sourceDirPath [

	| packagesDirectories |

	self validateDirectory: sourceDirPath.
	self readSourcePropertiesFrom: sourceDirPath.
	packagesDirectories :=
		(fileSystem subDirectoriesOf: sourceDirPath asString)
			collect: [:each | fileSystem cfsPathFrom: each].
	self readPackageDirectories: packagesDirectories
]

{ #category : 'Reading' }
TonelReader >> readPackagesFrom: aPath [

	
	#deprecated.
	self readFrom: aPath
]

{ #category : 'Reading',
  #vaVisibility : 'private' }
TonelReader >> readSourceDirectoryNameFrom: aPath [
	"Private - Reads the sources directory name from the project path aPath."

	| projectPropertiesPath sourceDirectoryName |

	projectPropertiesPath := aPath append: '.project'.
	projectPropertiesPath exists
		ifTrue: [
			fileSystem
				createReadStreamOn: projectPropertiesPath asString
				do: [:aStream | | projectProperties |
					projectProperties := (STONReader on: aStream) next.
					sourceDirectoryName :=
						projectProperties
							at: #srcDirectory
							ifAbsent: [projectProperties at: 'srcDirectory' ifAbsent: [nil]]]].
	^sourceDirectoryName
]

{ #category : 'Reading',
  #vaVisibility : 'private' }
TonelReader >> readSourcePropertiesFrom: aSourceDirPath [
	"Private - Reads the sources properties from the sources directory aPath.
	 Raise an error if the properties file does not exists or specifies a format
	 other than Tonel."

	| sourcePropertiesPath |

	sourcePropertiesPath := aSourceDirPath append: '.properties'.
	sourcePropertiesPath exists
		ifFalse: [
			self error: (
				'Cannot find Tonel .properties file at the %1 sources directory'
					bindWith: aSourceDirPath asString)].
	fileSystem
		createReadStreamOn: sourcePropertiesPath asString
		do: [:aStream | | format |
			sourceProperties := (STONReader on: aStream) next.
			format :=
				sourceProperties
					at: #format
					ifAbsent: [sourceProperties at: 'format' ifAbsent: [#unknown]].
			format asSymbol = #tonel
				ifFalse: [self error: 'The format specified on .properties must be Tonel']]
]

{ #category : 'Accessing' }
TonelReader >> repositoryPath [

	^repositoryPath
]

{ #category : 'Reading-Project',
  #vaVisibility : 'private' }
TonelReader >> validateDirectory: aPath [
	"Private - Validates whether aPath for the sources directory exists.
	 Raises an error if it doesn't."

	aPath exists
		ifFalse: [
			self
				error: (('Sources directory <1p> does not exist.') expandMacrosWith: aPath)]
]
