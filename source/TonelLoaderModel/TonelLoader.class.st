Class {
	#name : 'TonelLoader',
	#superclass : 'Object',
	#instVars : [
		'reader',
		'applications',
		'subApplications'
	],
	#classVars : [
		'CompilerWarningLevel',
		'AppSuperGroupSetting',
		'AppNameSuffix'
	],
	#category : 'TonelLoaderModel'
}

{
	#category : 'Accessing'
}
TonelLoader class >> appNameSuffix [
	"Read comment of appNameSuffix:"

	^ AppNameSuffix ifNil: [ AppNameSuffix := self defaultAppNameSuffix ]
]

{
	#category : 'Accessing'
}
TonelLoader class >> appNameSuffix: rootAppSuffix [
	"Allows the user to specify the suffix to be used for the created root application
	by the MetacelloImporter. The default will be 'App'. 

	Arguments:
		rootAppSuffix - <String> The root application name suffix. 
	 "
	
	AppNameSuffix := rootAppSuffix
]

{
	#category : 'Accessing'
}
TonelLoader class >> appSuperGroupSetting [
	"Read comment of appSuperGroupSetting:"
	
	^ AppSuperGroupSetting ifNil: [ AppSuperGroupSetting := self defaultAppSuperGroupSetting ]
]

{
	#category : 'Accessing'
}
TonelLoader class >> appSuperGroupSetting: superGroup [
	"Allows the user to specify the 'Super Group' setting to be used for the created applications and subapplications
	by the MetacelloImporter. The default will be #none. 

	Arguments:
		superGroup - <Symbol> Possible values are #none, #world and #group.
	 "
	AppSuperGroupSetting := superGroup
]

{
	#category : 'Accessing'
}
TonelLoader class >> compilerWarningLevel [
	 "Read comment of compilerWarningLevel:"
	 
	^ CompilerWarningLevel ifNil: [ CompilerWarningLevel := self defaultCompilerWarningLevel ]
]

{
	#category : 'Accessing'
}
TonelLoader class >> compilerWarningLevel: aLevel [
	"Allows the user to specify the compiler warning level used while MonticelloImporter compiles 
	 the new methods. When we are importing code, we want to get our code in VA as soon as possible.
	 Therefore, the default is the less restrictive level (level 0) rather than the current one. Once the
	 import finishes, the warning is rollbacked to the previous level. For mode details, read comment in
	 EsCompiler >>#defaultWarningLevel.
	 
	Arguments:
		aLevel - <Number> Possible values are from 0 to 3. 
	 "
	CompilerWarningLevel := aLevel
]

{
	#category : 'Accessing - Defaults'
}
TonelLoader class >> defaultAppNameSuffix [
	
	^ 'App'
]

{
	#category : 'Accessing - Defaults'
}
TonelLoader class >> defaultAppSuperGroupSetting [
	
	^ #none
]

{
	#category : 'Accessing - Defaults'
}
TonelLoader class >> defaultCompilerWarningLevel [
	
	^ 0
]

{
	#category : 'instance creation'
}
TonelLoader class >> on: aTonelReader [

	"Creates a new instance of receiver usin aTonelReader as its reader."
	
	^self new setReader: aTonelReader
]

{
	#category : 'lookup'
}
TonelLoader >> applicationNamed: aString [
	"Returns the application with name aString or raise an error if not found."

	^self applications detect: [:one | one name = aString]
]

{
	#category : 'accessing'
}
TonelLoader >> applications [

	applications ifNil: [self initializeApplications].
	^applications
]

{
	#category : 'loading'
}
TonelLoader >> checkRepositoryContents [
	self applications isEmpty 
		ifTrue: 
			[self error: 'The selected directory does not contain any Tonel Package']
]

{
	#category : 'interacting'
}
TonelLoader >> confirm: aString [


	^true
]

{
	#category : 'initializing',
	#vaVisibility : 'private'
}
TonelLoader >> createReaderForRepository: directoryPath [

	self setReader: (TonelReader new).
	self reader readPackagesFrom: directoryPath.
]

{
	#category : 'initializing',
	#vaVisibility : 'private'
}
TonelLoader >> initializeApplications [
	"Initializes receiver applications ensuring each application initializes its subapplications deeply."

	applications := (reader packages select: [:each | each parent isNil]) 
				collect: [:each | TonelLoaderApplication on: each in: self].
	applications do: [:each | each initializeSubApplicationsWithRoot: each]
]

{
	#category : 'loading',
	#vaVisibility : 'private'
}
TonelLoader >> load [
	"Private - Loads all the applications in the reader.
	 NOTE: The reader sorts the packages in alphabetical order, so if there is any dependency 
	 between them, it might fail."

	self loadApplications: self applications
]

{
	#category : 'loading'
}
TonelLoader >> loadApplication: aTonelApplication [

	self loadApplications: (Array with: aTonelApplication)
]

{
	#category : 'loading'
}
TonelLoader >> loadApplicationNamed: aStringOrSymbol [

	self loadApplication: (self applicationNamed: aStringOrSymbol)
]

{
	#category : 'loading'
}
TonelLoader >> loadApplications: aCollection [

	| confirmer |

	confirmer := System image confirmer: self.
	[aCollection do: [:each | (TonelApplicationLoader on: each in: self) load]]
		ensure: [System image confirmer: confirmer]
]

{
	#category : 'loading'
}
TonelLoader >> loadApplicationsNamed: aCollection [

	self loadApplications: (aCollection collect: [:each | self applicationNamed: each])
]

{
	#category : 'accessing'
}
TonelLoader >> loadedApplications [

	^System loadedApplications
]

{
	#category : 'logging'
}
TonelLoader >> log: aString [

	self class owningImage logApplicationNotice: aString.
]

{
	#category : 'interacting'
}
TonelLoader >> proceed: aString [


	^true
]

{
	#category : 'accessing'
}
TonelLoader >> reader [
	"Returns the TonelReader of receiver."
	
	^reader
]

{
	#category : 'initializing',
	#vaVisibility : 'private'
}
TonelLoader >> setReader: aTonelReader [

	"Assigns aTonelReader as receiver's reader."
	
	reader := aTonelReader
]

{
	#category : 'lookup'
}
TonelLoader >> subApplicationNamed: aString [

	^self subApplications
		detect: [:one | one name = aString]
		ifNone: [| subAppPackage |
			subAppPackage := reader lookupPackageNamed: aString.
			self subApplications add: (TonelLoaderSubApplication on: subAppPackage in: self)]
]

{
	#category : 'accessing'
}
TonelLoader >> subApplications [

	^subApplications ifNil: [subApplications := OrderedCollection new]
	
]

{
	#category : 'lookup',
	#vaVisibility : 'private'
}
TonelLoader >> subApplicationsFor: aTonelLoaderSubApplication [
	"Returns the collection of subapplications of aTonelLoaderSubApplication."

	^(self reader packages
		select: [:each | each parent = aTonelLoaderSubApplication packageDefinition name])
			collect: [:each | self subApplicationNamed: each name]
]
