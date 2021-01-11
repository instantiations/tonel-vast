Class {
	#name : 'EmLibrarySnapshot',
	#superclass : 'Object',
	#instVars : [
		'classes',
		'log',
		'subApplications',
		'applications',
		'timeStamp'
	],
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmLibrarySnapshot class >> take [

	^self new initialize take
]

{ #category : 'accessing-private' }
EmLibrarySnapshot >> classes [

	^classes
]

{ #category : 'loading',
  #vaVisibility : 'private' }
EmLibrarySnapshot >> findAllApplicationsToLoadWith: aCollection [

	"Private - Find all prerequisites of the applications which are not loaded and ask
	 the user if they should be loaded also. If not answer nil.
	 
	 NOTE: This is a modified version of EtBrowser's version, that delegates on receiver to use its own strategy.
	 "

	| browser required applicationNames stream prereqNames toLoad cursorPosition prereq others |
	browser := EtBrowser new.
	required := browser managerInterface 
				allUnloadedPrerequisitesFor: aCollection.
	required isEmpty ifTrue: [^aCollection].
	aCollection size = 1 
		ifTrue: [applicationNames := aCollection first name]
		ifFalse: 
			[stream := WriteStream on: (browser stringClass new: 100).
			(aCollection asSortedCollection: Class sortBlock) do: 
					[:app | 
					stream
						cr;
						nextPutAll: '      ' , app name].	"$NON-NLS$"
			applicationNames := stream contents].
	stream := WriteStream on: (browser stringClass new: 100).
	required keys asSortedCollection do: 
			[:appName | 
			stream
				cr;
				nextPutAll: '      ' , appName].	"$NON-NLS$"
	prereqNames := stream contents.
	toLoad := aCollection asOrderedCollection.
	cursorPosition := System cursorPosition.
	required associationsDo: 
			[:assoc | 
			(toLoad detect: [:app | app symbol = assoc key] ifNone: []) isNil 
				ifTrue: 
					[assoc value isEmpty 
						ifTrue: 
							[| application |
							application := assoc key.
							^self signalMissingPrerequisiteOf: application].	"$NLS$ The prerequisite %1 does not exist in the library."
					assoc value size = 1 
						ifTrue: [prereq := assoc value first]
						ifFalse: 
							[| application prereqs |
							application := assoc key.
							prereqs := assoc value.
							prereq := self selectPrerequisiteEditionOf: application in: prereqs].
					prereq isNil ifTrue: [^nil].
					others := self findAllApplicationsToLoadWith: (Array with: prereq).
					others isNil ifTrue: [^nil].
					toLoad addAll: others]].
	^toLoad
]

{ #category : 'initializing' }
EmLibrarySnapshot >> initialize [

	super initialize.
	log := OrderedCollection new.
	applications := Dictionary new.
	subApplications := Dictionary new.
	classes := Dictionary new
]

{ #category : 'operations' }
EmLibrarySnapshot >> loadedAppsAndSubApps [
	^(applications keys, subApplications keys) collect: [:name | Smalltalk classAt: name ]
]

{ #category : 'accessing-private',
  #vaVisibility : 'private' }
EmLibrarySnapshot >> owningImage [

	^self class owningImage
]

{ #category : 'operations' }
EmLibrarySnapshot >> restore [

	self restore: false
]

{ #category : 'operations' }
EmLibrarySnapshot >> restore: purgeEditions [

	| newApps newSubApps appsToLoad |

	newApps := Dictionary new.
	newSubApps := Dictionary new.

	(System image loadedSubApplications select: [:each | each isSubApplication]) do: [:currSubApp |
		subApplications
			at: currSubApp name
			ifAbsent: [newSubApps at: currSubApp name put: currSubApp timeStamp]].
	System image loadedApplications do: [:currApp |
		applications at: currApp name ifAbsent: [newApps at: currApp name put: currApp timeStamp]].


	EmInterface current removeApplications: (newApps keys collect: [:each | Smalltalk classAt: each]).
	(newSubApps keys collect: [:each | Smalltalk classAt: each]) do: [:subApp | 
		(newApps includes: subApp rootApplication) ifFalse: [
		subApp parent removeSubApplication: subApp]].
	
	purgeEditions
		ifTrue: [
			newSubApps keysAndValuesDo: [:subAppName :ts |
				(SubApplication partsRecordClass purge: subAppName at: ts)]].

	EmLibraryCache current flushEntriesForSubApplicationNames: newSubApps keys asArray.


	appsToLoad := OrderedCollection new.
	newApps keysAndValuesDo: [:appName :ts |
		applications
			at: appName
			ifPresent: [:prevTs |
				appsToLoad addAll:
					((Application shadowsFor: appName) select: [:shadow | shadow timeStamp = prevTs])]].
	EmClassDevelopment imageBuilder loadApplications: appsToLoad.

	purgeEditions
		ifTrue: [
			newApps keysAndValuesDo: [:appName :ts |
				(Application partsRecordClass purge: appName at: ts)]].

	EmLibraryCache current flushEntriesForApplicationNames: newApps keys asArray



]

{ #category : 'loading' }
EmLibrarySnapshot >> signalMissingPrerequisiteOf: application [

	^System
		message: ((NlsCatEMT residentMsg: 'MxEMT25') bindWith: application)
]

{ #category : 'operations' }
EmLibrarySnapshot >> take [

	timeStamp := EmTimeStamp now.
	System image loadedApplications
		do: [:app | applications at: app name put: app timeStamp].
	System image loadedSubApplications		
		do: [:app | subApplications at: app name put: app timeStamp].
	self loadedAppsAndSubApps do: 
			[:appOrSubapp | 
			#(#defined #extended) do: 
					[:key | 
					(appOrSubapp perform: key) do: 
							[:class | 
							(classes at: class symbol ifAbsentPut: [Dictionary new]) at: key
								put: appOrSubapp symbol -> (appOrSubapp timeStampFor: class)]]]
]

{ #category : 'accessing' }
EmLibrarySnapshot >> timeStamp [
	^timeStamp ifNil: [EmTimeStamp undefined]
]

{ #category : 'accessing' }
EmLibrarySnapshot >> timeStamp: anObject [
	timeStamp := anObject
]

{ #category : 'accessing-private' }
EmLibrarySnapshot >> timeStampAt: className in: appName [

	^((classes at: className ifAbsentPut: [Dictionary new]) at: #defined ifAbsent: [appName -> EmTimeStamp undefined]) value
]

{ #category : 'accessing' }
EmLibrarySnapshot >> timeStampForApplication: aSymbol [

	^applications at: aSymbol ifAbsent: [EmTimeStamp undefined]
]
