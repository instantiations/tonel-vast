Class {
	#name : 'TonelLoaderGitParentBaseEditionStrategy',
	#superclass : 'TonelLoaderBaseEditionStrategy',
	#instVars : [
		'parentCommitId'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'operations',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> executeGitCommand [
	| starter process |
	starter := OsProcessStarter shell: 'git cat-file commit HEAD'.
	starter workingDirectory: self loader repositoryPath.
	starter redirectOutputToPipe.
	process := starter start.
	^process
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> initializeParentCommitId [
	| execOkay readStream process |
	process := self executeGitCommand.
	process waitForCompletion.
	execOkay := process exitCode isZero.
	readStream := process outputStream upToEnd readStream.
	(execOkay not or: [readStream size isZero]) 
		ifTrue: [self signalParentCommitReadError]
		ifFalse: [self readParentCommitFrom: readStream]
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> parentCommitId [

	parentCommitId ifNil: [self initializeParentCommitId].
	^parentCommitId
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> readParentCommitFrom: readStream [

	| parentCommitData line |
	line := readStream nextLine.
	(line copyFrom: 1 to: (4 min: line size)) = 'tree' 
		ifFalse: [self signalParentCommitReadError].
	parentCommitData := readStream nextLine subStrings.
	(parentCommitData size = 2 and: [parentCommitData first = 'parent']) 
		ifFalse: [self signalParentCommitReadError].
	parentCommitId := parentCommitData last first: 7
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> resetParentCommitId [
	parentCommitId := nil
]

{ #category : 'operations' }
TonelLoaderGitParentBaseEditionStrategy >> selectBaseEditionOf: aTonelSubApplication [
	"Answers the base edition of aTonelApplication,
	trying to match the versionName of aTonelSubApplication
	with that of the parent commit id of receiver's repository."
	
	^aTonelSubApplication availableShadows detect: [:one | one versionName includesSubstring: self parentCommitId ] ifNone: [aTonelSubApplication availableShadows first]
]

{ #category : 'operations' }
TonelLoaderGitParentBaseEditionStrategy >> selectPrerequisiteEditionOf: application in: aCollection [
	"Select the edition of the prerequisite application anApplication
	 in aCollection of prerequisites, trying to match the versionName
	 of the prerequisite with that of the parent commit id of receiver's repository."
	
	| sortedPrereqs |
	sortedPrereqs := (aCollection 
				asSortedCollection: [:a :b | a timeStamp <= b timeStamp]) asArray.
	^sortedPrereqs 
		detect: [:one | one versionName includesSubstring: self parentCommitId]
		ifNone: [sortedPrereqs last]
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> setLoader: aTonelLoader [

	super setLoader: aTonelLoader.
	self resetParentCommitId
]

{ #category : 'errors',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> signalParentCommitReadError [
	self error: 'Could not get the parent commit. Check if the path has a valid git repository or if git command is in the PATH.'
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> tempGitOutputPath [
	^'commit.parent'
]
