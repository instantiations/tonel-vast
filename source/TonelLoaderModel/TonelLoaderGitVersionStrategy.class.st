Class {
	#name : 'TonelLoaderGitVersionStrategy',
	#superclass : 'TonelLoaderVersionStrategy',
	#instVars : [
		'versionNamePattern'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelLoaderGitVersionStrategy class >> description [

	^'Use git repository commit hash and branch name'
]

{ #category : 'versioning',
  #vaVisibility : 'private' }
TonelLoaderGitVersionStrategy >> attemptVersionFromGit [
	"Private - Attempts to read git metadata from the repository path of the loader (if available)."

	self loader reader repositoryPath
		ifNil: [TonelLoaderError signal: ('There is no repository path specified')]
		ifNotNil: [:repoPath | | gitBranchCommitFile gitBranchPath gitHeadPath commitHash commitDate |
			gitHeadPath := (repoPath append: '.git') append: 'HEAD'.
			gitHeadPath exists
				ifTrue: [| refsPathString headFile stat |
					[
						headFile := CfsReadFileStream open: gitHeadPath asString.
						refsPathString := headFile nextLine.
						refsPathString := refsPathString copyFrom: 6 to: refsPathString size]
							ensure: [headFile close].
					gitBranchPath := (repoPath append: '.git') append: refsPathString.
					gitBranchPath exists
						ifTrue: [
							gitBranchCommitFile := CfsReadFileStream open: gitBranchPath asString.

							[
								commitHash := gitBranchCommitFile nextLine first: 7.
								stat := gitBranchPath cfsStat.
								commitDate :=
									DateAndTime date: stat stMtime first time: stat stMtime last]
										ensure: [gitBranchCommitFile close].
							commitHash isEmptyOrNil
								ifTrue: [
									TonelLoaderError signal: ('Could not retrieve commit hash from the repository')
								]
								ifFalse: [
									^
										(self versionNamePattern expandMacrosWith: commitHash with: gitBranchPath parts last with: commitDate)]]]
				ifFalse: [
					TonelLoaderError signal: (
						'There is no git repository at <1p>'
							expandMacrosWith: self loader reader repositoryPath)]

			].
			^nil
]

{ #category : 'versioning',
  #vaVisibility : 'private' }
TonelLoaderGitVersionStrategy >> defaultVersionNamePattern [
	^'<1s>-<2s>'
]

{ #category : 'versioning' }
TonelLoaderGitVersionStrategy >> versionFor: aTonelApplication [

	^self attemptVersionFromGit
]

{ #category : 'accessing' }
TonelLoaderGitVersionStrategy >> versionNamePattern [
	^versionNamePattern 
		ifNil: [versionNamePattern := self defaultVersionNamePattern]
]

{ #category : 'accessing' }
TonelLoaderGitVersionStrategy >> versionNamePattern: aString [
	versionNamePattern := aString
]
