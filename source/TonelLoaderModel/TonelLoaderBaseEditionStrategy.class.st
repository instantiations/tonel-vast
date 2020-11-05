Class {
	#name : 'TonelLoaderBaseEditionStrategy',
	#superclass : 'TonelLoaderStrategy',
	#instVars : [
		'versionedEditionsOnly'
	],
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelLoaderBaseEditionStrategy >> confirmLoadPrerequisites: prereqNames of: applicationNames using: browser [

	^self loader confirm: ((NlsCatEMT residentMsg: 'MxEMT24') addLineDelimiters 
				bindWith: applicationNames
				with: prereqNames)
]

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelLoaderBaseEditionStrategy >> filteredBaseEditions: shadowEditions [

	^self versionedEditionsOnly
		ifTrue: [shadowEditions select: [:each | each isVersion]]
		ifFalse: [shadowEditions]
]

{ #category : 'lookup',
  #vaVisibility : 'private' }
TonelLoaderBaseEditionStrategy >> findAllApplicationsToLoadWith: aCollectionOfApplications [

	"Private - Find all prerequisites of the applications which are not loaded and ask
	 the user if they should be loaded also. If not answer nil.
	 
	 NOTE: This is a modified version of EtBrowser's version, that delegates on receiver to use its own strategy.
	 "

	| required applicationNames stream prereqNames toLoad prereq others |
	required := EmInterface current 
				allUnloadedPrerequisitesFor: aCollectionOfApplications.
	required isEmpty ifTrue: [^aCollectionOfApplications].
	aCollectionOfApplications size = 1 
		ifTrue: [applicationNames := aCollectionOfApplications first name]
		ifFalse: 
			[stream := WriteStream on: (self stringClass new: 100).
			(aCollectionOfApplications asSortedCollection: Class sortBlock) do: 
					[:app | 
					stream
						cr;
						nextPutAll: '      ' , app name].	"$NON-NLS$"
			applicationNames := stream contents].
	stream := WriteStream on: (self stringClass new: 100).
	required keys asSortedCollection do: 
			[:appName | 
			stream
				cr;
				nextPutAll: '      ' , appName].	"$NON-NLS$"
	prereqNames := stream contents.
	(self 
		confirmLoadPrerequisites: prereqNames
		of: applicationNames
		using: nil) ifFalse: [^nil].	"$NLS$ To load %1 the following prerequisite(s) must also be loaded:\%2.\\Do you wish to load them also?"
	toLoad := aCollectionOfApplications asOrderedCollection.
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

{ #category : 'testing' }
TonelLoaderBaseEditionStrategy >> hasSelectableBaseEditionFor: tonelAppOrSub [

	^(self filteredBaseEditions: (tonelAppOrSub availableShadows)) notEmpty
]

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelLoaderBaseEditionStrategy >> loadBaseEditionAndPrerequisitesOf: baseEdition [

	| baseEditionPrerequisites tonelAppsToLoad |

	baseEditionPrerequisites := (self findAllApplicationsToLoadWith: (Array with: baseEdition)).
	tonelAppsToLoad := OrderedCollection new.

	baseEditionPrerequisites do: [:emApp |
		self loader applications do: [:tonelApp |
			(baseEdition name ~= tonelApp identifier and: [emApp name = tonelApp identifier])
				ifTrue: [tonelAppsToLoad add: tonelApp]]].

	tonelAppsToLoad isEmpty
		ifTrue: [self loadEMBaseEditionAndPrerequisites: baseEditionPrerequisites]
		ifFalse: [
			self loader loadApplications: (
				tonelAppsToLoad collect: [:emApp | self loader applicationNamed: emApp name asString]).
			EmImageBuilder loadApplications:
				(baseEditionPrerequisites reject: [:emApp | tonelAppsToLoad includes: emApp])]
]

{ #category : 'operations' }
TonelLoaderBaseEditionStrategy >> loadBaseEditionFor: aTonelSubApplication [

	"This method contains some voodoo."

	| baseEdition |
	baseEdition := self selectBaseEditionOf: aTonelSubApplication.	"$NLS$ Application %1 exists but is not loaded. Please choose a base version."	"$NLS$ %1 %2"
	baseEdition 
		ifNil: [self signalNoBaseEditionErrorFor: aTonelSubApplication].	"$NLS$ You need to choose a base edition from which to create %1"
	(self loadBaseEditionAndPrerequisitesOf: baseEdition) ifNil: 
			[self signalLoadErrorOf: aTonelSubApplication	"$NLS$ Could not load base edition of %1. Load aborted."]
]

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelLoaderBaseEditionStrategy >> loadEMBaseEditionAndPrerequisites: baseEditionPrerequisites [

	| editionsToLoad |

	editionsToLoad :=
		baseEditionPrerequisites reject: [:emApp |
			self loader loadedApplications anySatisfy: [:tonelApp | tonelApp identifier = emApp name]].

	editionsToLoad do: [:each | EmImageBuilder loadApplications: (Array with: each)]
]

{ #category : 'lookup' }
TonelLoaderBaseEditionStrategy >> selectBaseEditionOf: aTonelSubApplication [

	self subclassResponsibility
]

{ #category : 'operations' }
TonelLoaderBaseEditionStrategy >> selectPrerequisiteEditionOf: application [

	| shadows |
	^(shadows := Application shadowsFor: application name) isEmpty 
		ifTrue: [nil]
		ifFalse: [self selectPrerequisiteEditionOf: application in: shadows]
]

{ #category : 'operations' }
TonelLoaderBaseEditionStrategy >> selectPrerequisiteEditionOf: application in: prereqs [

	self subclassResponsibility
]

{ #category : 'errors',
  #vaVisibility : 'private' }
TonelLoaderBaseEditionStrategy >> signalLoadErrorOf: aTonelSubApplication [

	^TonelLoaderError signal: (TonelMsg18 bindWith: aTonelSubApplication)	"$NLS$ Could not load base edition of %1. Load aborted."
]

{ #category : 'errors',
  #vaVisibility : 'private' }
TonelLoaderBaseEditionStrategy >> signalMissingPrerequisiteOf: application [

	TonelLoaderError signal: ((NlsCatEMT residentMsg: 'MxEMT25') bindWith: application).
	^nil
]

{ #category : 'errors',
  #vaVisibility : 'private' }
TonelLoaderBaseEditionStrategy >> signalNoBaseEditionErrorFor: aTonelSubApplication [

	^TonelLoaderError signal: (TonelMsg08 bindWith: aTonelSubApplication)
]

{ #category : 'accessing' }
TonelLoaderBaseEditionStrategy >> versionedEditionsOnly [
	^versionedEditionsOnly ifNil: [versionedEditionsOnly := true]
]

{ #category : 'accessing' }
TonelLoaderBaseEditionStrategy >> versionedEditionsOnly: anObject [
	versionedEditionsOnly := anObject
]
