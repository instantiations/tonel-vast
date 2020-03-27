Class {
	#name : 'TonelLoaderGitParentBaseEditionStrategy',
	#superclass : 'TonelLoaderBaseEditionStrategy',
	#instVars : [
		'parentCommitId'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> executeGitCommand [
	| starter execOkay |
	starter := AbtShellProgramStarter new.
	starter currentDirectory: self loader repositoryPath asString.
	starter programName: 'git'.
	starter programInput: 'cat-file commit HEAD'.
	starter stdoutPath: self tempGitOutputPath.
	execOkay := starter startProgram.
	^execOkay
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> initializeParentCommitId [

	| execOkay mustWait outfile readStream |

	execOkay := self executeGitCommand.
	(Delay forMilliseconds: 250) wait.
	[
		readStream :=
			CfsFileStream read: (self loader repositoryPath append: self tempGitOutputPath) asString.
		(execOkay not or: [readStream isCfsError])
			ifTrue: [self signalParentCommitReadError]
			ifFalse: [| parentCommitData  line |
				line  := readStream nextLine. 
				((line copyFrom: 1 to: (4 min: line size)) = 'tree') ifFalse: [self signalParentCommitReadError].
				parentCommitData := readStream nextLine subStrings.
				(parentCommitData size = 2 and: [parentCommitData first = 'parent'])
					ifFalse: [self signalParentCommitReadError].
				parentCommitId := parentCommitData last first: 7]]
					ensure: [
						readStream isCfsError ifFalse: [readStream close].
						(self loader repositoryPath append: self tempGitOutputPath)
							ifNotNil: [:outFile | outFile exists ifTrue: [outFile delete]]]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> parentCommitId [

	parentCommitId ifNil: [self initializeParentCommitId].
	^parentCommitId
]

{ #category : 'Not categorized' }
TonelLoaderGitParentBaseEditionStrategy >> selectBaseEditionOf: aTonelSubApplication [

	
	^aTonelSubApplication availableShadows detect: [:one | one versionName includesSubstring: self parentCommitId ] ifNone: [aTonelSubApplication availableShadows last]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> signalParentCommitReadError [
	self error: 'Could not get the parent commit. Check if the path has a valid git repository or if git command is in the PATH.'
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderGitParentBaseEditionStrategy >> tempGitOutputPath [
	^'commit.parent'
]
