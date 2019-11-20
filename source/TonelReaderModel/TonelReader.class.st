Class {
	#name : 'TonelReader',
	#superclass : 'Object',
	#instVars : [
		'fileSystem',
		'sourceProperties',
		'packages',
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

{ #category : 'Reading - Project',
  #vaVisibility : 'private' }
TonelReader >> addContentFrom: filePath toPackage: package [

	filePath readStreamDo: [:aStream | | result |
		result := TonelParser parseStream: aStream.
		result first addToPackage: package withAll: (result size > 1 ifTrue: [result copyFrom: 2 to: result size] ifFalse: [Array new])]
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelReader >> addPackage: aPackageDefinition [

	^self packages add: aPackageDefinition
]

{ #category : 'Reading - Project' }
TonelReader >> computeSourceDirFrom: aPath [

	^(self readSourceDirectoryNameFrom: aPath) 
		ifNil: [aPath]
		ifNotNil: [:dir | aPath append: dir]
]

{ #category : 'Not categorized' }
TonelReader >> defaultSourceDirectory [
	^'.'
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelReader >> initializeOn: aFileSystem [

	fileSystem := aFileSystem.
	
	
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelReader >> lookupPackage: aPackageDefinition ifNone: aBlock [

	^self lookupPackageNamed: aPackageDefinition name ifNone: aBlock
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelReader >> lookupPackageNamed: aString [

	^self packages detect: [:each | each name = aString] ifNone: [self packages errorNotFound]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelReader >> lookupPackageNamed: aString ifNone: aBlock [
	^self packages detect: [:each | each name = aString] ifNone: aBlock
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelReader >> packageFrom: aPackageDefinition [

	^(self lookupPackage: aPackageDefinition ifNone: [self addPackage: aPackageDefinition]) 
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelReader >> packages [

	^packages ifNil: [	packages := OrderedCollection new]
]

{ #category : 'Reading - Project',
  #vaVisibility : 'private' }
TonelReader >> readPackageDirectories: aCollection [

	aCollection do: [:each | self readPackageFrom: each]
]

{ #category : 'Reading - Project',
  #vaVisibility : 'private' }
TonelReader >> readPackageFileFrom: packageDirectory [

	| package |
	fileSystem
		createReadStreamOn: (packageDirectory append: 'package.st') asString
		during: [:stream | package := self packageFrom: (TonelParser parseStream: stream) first].
	^package
	





]

{ #category : 'Reading - Project',
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

{ #category : 'Reading - Project' }
TonelReader >> readPackages: aCollection fromSourceDir: sourceDirPath [

	| packagesDirectories |
	self validateDirectory: sourceDirPath.
	self readSourcePropertiesFrom: sourceDirPath.
	packagesDirectories := (fileSystem subDirectoriesOf: sourceDirPath asString) collect: [:each | fileSystem cfsPathFrom: each].
	self readPackageDirectories: packagesDirectories
]

{ #category : 'Reading - Project' }
TonelReader >> readPackagesFrom: aPath [

	| sourceDirectory |
	repositoryPath := aPath.
	sourceDirectory := self computeSourceDirFrom: aPath.
	self readPackages: nil fromSourceDir: sourceDirectory
]

{ #category : 'Reading - Project' }
TonelReader >> readSourceDirectoryNameFrom: aPath [

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

{ #category : 'Reading - Project',
  #vaVisibility : 'private' }
TonelReader >> readSourcePropertiesFrom: aSourceDirPath [

	| sourcePropertiesPath |

	sourcePropertiesPath := aSourceDirPath append: '.properties'.
	sourcePropertiesPath exists ifFalse: [
		self error: ('Cannot find Tonel .properties file at the %1 sources directory' bindWith: aSourceDirPath asString)
	].
	fileSystem
		createReadStreamOn: sourcePropertiesPath asString
		do: [:aStream | | format |
			sourceProperties := (STONReader on: aStream) next.
			format :=
				sourceProperties
					at: #format
					ifAbsent: [sourceProperties at: 'format' ifAbsent: [#unknown]].
			format asSymbol = #tonel ifFalse: [self error: 'The format specified on .properties must be Tonel']]
]

{ #category : 'Accessing' }
TonelReader >> repositoryPath [

	^repositoryPath
]

{ #category : 'Reading - Project',
  #vaVisibility : 'private' }
TonelReader >> validateDirectory: aSourceDirectory [

	aSourceDirectory exists ifFalse: [self error:( ('Source directory <1p> does not exist.') expandMacrosWith: aSourceDirectory)]
]
