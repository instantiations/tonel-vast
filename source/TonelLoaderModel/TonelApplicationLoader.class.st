Class {
	#name : 'TonelApplicationLoader',
	#superclass : 'Object',
	#instVars : [
		'tonelApplication',
		'loader',
		'versionName'
	],
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{
	#category : 'Not categorized'
}
TonelApplicationLoader class >> on: aTonelApplication in: aTonelLoader [

	^self new
		setTonelApplication: aTonelApplication loader: aTonelLoader;
		yourself
]

{
	#category : 'querying'
}
TonelApplicationLoader >> allLoadedApplications [
	
	^self loader loadedApplications
]

{
	#category : 'versioning',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> attemptVersionFromGit [
	"Private - Attempts to read git metadata from the repository path of the loader (if available)."

	(self loader reader repositoryPath) ifNotNil: [:repoPath | | gitBranchCommitFile gitBranchPath
		  gitHeadPath commitHash commitDate |
		gitHeadPath := ((repoPath append: '.git') append: 'HEAD').
		gitHeadPath exists
			ifTrue: [| refsPathString headFile stat |
				[
					headFile := CfsReadFileStream open: gitHeadPath asString.
					refsPathString := headFile nextLine.
					refsPathString := refsPathString copyFrom: 6 to: refsPathString size]
						ensure: [headFile close].
				gitBranchPath := (((repoPath append: '.git') append: refsPathString)).
				gitBranchPath exists
					ifTrue: [
						gitBranchCommitFile := CfsReadFileStream open: gitBranchPath asString.
						[
							commitHash := (gitBranchCommitFile nextLine first: 7).
							stat := gitBranchPath cfsStat.
							commitDate := DateAndTime
								date: stat stMtime first
								time: stat stMtime last]
									ensure: [gitBranchCommitFile close].
						commitHash isEmptyOrNil
							ifFalse: [
								self versionName:
									(commitHash , (' (<1p>)' expandMacrosWith: commitDate))]]]]
]

{
	#category : 'loading-internal'
}
TonelApplicationLoader >> autogenerateClassSideNewInitializers [

	| allDefinedClasses superclasses |

	allDefinedClasses := tonelApplication allDefinedClasses.
	superclasses := self detectAllRootSuperclassesWithinApp.
	superclasses do: [:aSuperclass | | tonelClass |
		tonelClass := allDefinedClasses at: aSuperclass.
		"Only generate #new if it does not have it...we don't want to override it"
		tonelClass includesClassSideNewMethod
			ifFalse: [
				tonelClass addMethod: (TonelReaderMethodDefinition newInitializeMethodFor: aSuperclass)]]
]

{
	#category : 'loading-internal'
}
TonelApplicationLoader >> checkClassExtensions [

	self tonelApplication checkClassExtensionsExcepting: self tonelApplication allDefinedClassNames
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> checkForUnloadedApplication [

	self tonelApplication loadBaseApplication
]

{
	#category : 'loading-internal'
}
TonelApplicationLoader >> checkSuperclasses [

	self tonelApplication checkSuperclassesExcepting: self tonelApplication allDefinedClasses
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> checkThatUserCanModifyApplication [

	self tonelApplication verifyBaseEditionUser
]

{
	#category : 'loading-prompters',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> choosePrerequisites [

	self tonelApplication prerequisites: (EtPrerequisiteCollectingPrompter
		prompt: ('Please select the prequisites for %1 (chains will be resolved after selection)' bindWith: self tonelApplication name)  "$NLS$ Please select the prequisites for %1 (chains will be resolved after selection)"
		chooseFrom: (
			self allLoadedApplications reject: [ :anApp | 
				self tonelApplication allDependentApplications includes: anApp ])
		current: self tonelApplication prerequisites
		alwaysRequired: (Set with: Kernel))
]

{
	#category : 'loading-prompters',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> chooseVersionName [
	"The version name string may be empty if the user pressed OK without entering
	 anything (or deleting the pre-entered name), or nil if the user pressed Cancel."

	[self attemptVersionFromGit] on: Error do: [:ex | ex return].
	self versionName: (
		(System prompt: TonelMsg11 answer: self versionName) "$NLS$ Enter the version name to be used for imported classes and applications"
			ifNil: ['']) "$NON-NLS$"
]

{
	#category : 'loading-internal'
}
TonelApplicationLoader >> convertSharedPoolClasses [
	"Enter the new method definition below and click 'Resume'."
	
	self tonelApplication convertSharedPoolClasses
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> createAndLoadApplication [
	"The contents of the Monticello file has been parsed and converted to classes representing
	 the content. Now process those classes to create real classes in the application."

	self
		chooseVersionName;
		createApplication;
		definePoolDictionaries;
		createClasses;
		prepareRemovedClasses;
		updateClassDefinitions;
		deleteRemovedClasses;
		loadApplication;
		deleteRemovedSubApplications;
		versionApplication;
		initializeApplication
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> createApplication [

	self tonelApplication create
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> createClasses [

	(self tonelApplication allClassesWithAssociation tonelSingleEdgeTopologicallySortedCollection
		reject: [:each | each key isSharedPool])
			do: [:ea | ea key createEditionIn: ea value]
]

{
	#category : 'querying'
}
TonelApplicationLoader >> definedClasses [

	^self tonelApplication definedClasses
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> definePoolDictionaries [

	self tonelApplication definePoolDictionaries
]

{
	#category : 'querying'
}
TonelApplicationLoader >> deletedClasses [

	^ self tonelApplication allClassesToRemoveIncludingExtensions: true
]

{
	#category : 'loading-internal'
}
TonelApplicationLoader >> deletedDefinedClasses [

	^ self tonelApplication allClassesToRemoveIncludingExtensions: false
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> deleteRemovedClasses [

	self deletedClasses tonelSingleEdgeTopologicallySortedCollection reverseDo: [ :ea |
		ea value deleteClasses: (Array with: ea key) ]
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> deleteRemovedSubApplications [

	self tonelApplication deleteRemovedSubApplications
]

{
	#category : 'querying'
}
TonelApplicationLoader >> detectAllRootSuperclassesWithinApp [

	| superclasses allDefinedClasses superclassBlock |

	allDefinedClasses := tonelApplication allDefinedClasses.
	superclasses := Set new.
	allDefinedClasses keysAndValuesDo: [:aClassName :tonelClass |
		superclassBlock := [:aClass |
			(allDefinedClasses includesKey: aClass superclassIdentifier asString)
				ifTrue: [
					superclassBlock
						value: (allDefinedClasses at: aClass superclassIdentifier asString)]
				ifFalse: [aClass name]].
		superclasses add: (superclassBlock value: tonelClass)].
	^superclasses
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> initializeApplication [

	self tonelApplication initialize
]

{
	#category : 'loading'
}
TonelApplicationLoader >> load [

	self loader log: (TonelMsg20 expandMacrosWith: self tonelApplication name).
	"self autogenerateClassSideNewInitializers."
	[
		self
			convertSharedPoolClasses;
			checkClassExtensions;
			checkSuperclasses;
			checkForUnloadedApplication;
			checkThatUserCanModifyApplication;
			choosePrerequisites;
			createAndLoadApplication]
				on: TonelLoaderError
				do: [:ex | ex pass]
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> loadApplication [

	self tonelApplication loadFor: self
]

{
	#category : 'accessing',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> loader [

	^loader
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> prepareRemovedClasses [

	EmClassCreator waitForMultipleChanges.
	self deletedDefinedClasses do: [ :ea | | eaClass methods |
		eaClass := ea key.
		"Remove the defined variables (in case a superclass will be defining
		  those variables as part of the load)"
		eaClass creatorClass
			createClassNamed: eaClass environmentKey
			in: eaClass environment
			for: (eaClass hasController ifTrue: [ eaClass controller ] ifFalse: [ nil ])
			subclassOf: eaClass superclass
			instanceShape: eaClass instanceShape
			classInstanceVariables: ''  "$NON-NLS$"
			instanceVariables: ''  "$NON-NLS$"
			classVariables: ''  "$NON-NLS$"
			sharedPoolNames: #().
		"Remove any pool dictionary definition methods (in case any other
		  class will be defining that pool as part of the load)"
		methods := OrderedCollection new.
		eaClass class methodDictionary do: [ :eachMethod |
			('_PRAGMA_*' match: eachMethod selector asString)	"$NON-NLS$"
				ifTrue: [ methods add: eachMethod ] ]. 
		EmInterface current removeMethods: methods asArray ].
	EmClassCreator finishedMultipleChanges
]

{
	#category : 'initializing',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> setTonelApplication: aTonelApplication loader: aTonelLoader [

	tonelApplication := aTonelApplication.
	loader  := aTonelLoader
]

{
	#category : 'accessing'
}
TonelApplicationLoader >> tonelApplication [

	^tonelApplication
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> updateClassDefinitions [

	EmClassCreator waitForMultipleChanges.
	self definedClasses tonelSingleEdgeTopologicallySortedCollection do: [:ea | ea updateVariables ].
	EmClassCreator finishedMultipleChanges
]

{
	#category : 'loading-internal',
	#vaVisibility : 'private'
}
TonelApplicationLoader >> versionApplication [

	self tonelApplication versionFor: self
]

{
	#category : 'accessing'
}
TonelApplicationLoader >> versionName [

	^versionName
]

{
	#category : 'accessing'
}
TonelApplicationLoader >> versionName: aVersionNameOrNil [

	
	versionName := aVersionNameOrNil
]
