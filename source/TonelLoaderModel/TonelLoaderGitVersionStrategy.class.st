Class {
	#name : 'TonelLoaderGitVersionStrategy',
	#superclass : 'TonelLoaderVersionStrategy',
	#instVars : [
		'versionNamePattern',
		'hashToVersionPart',
		'pathToVersionPart',
		'dateToVersionPart'
	],
	#classVars : [
		'DefaultBranchPathVersionPart',
		'DefaultCommitHashVersionPart',
		'DefaultCommitDateVersionPart',
		'DefaultVersionNamePattern'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Defaults - Version parts' }
TonelLoaderGitVersionStrategy class >> defaultBranchPathToVersionPart: aBlock [
	DefaultBranchPathVersionPart := aBlock
]

{ #category : 'Defaults - Version parts' }
TonelLoaderGitVersionStrategy class >> defaultCommitDateToVersionPart: aBlock [
	DefaultCommitDateVersionPart := aBlock
]

{ #category : 'Defaults - Version parts' }
TonelLoaderGitVersionStrategy class >> defaultCommitHashToVersionPart: aBlock [
	DefaultCommitHashVersionPart := aBlock
]

{ #category : 'Defaults - Version parts' }
TonelLoaderGitVersionStrategy class >> defaultVersionNamePattern: aPattern [
	"The version name pattern will be expanded with 3 arguments:
	 1. The commit hash representation
	 2. The branch path representation
	 3. The commit date representation"
	DefaultVersionNamePattern := aPattern
]

{ #category : 'Documentation' }
TonelLoaderGitVersionStrategy class >> description [

	^'Use git repository commit hash and branch name'
]

{ #category : 'Defaults - Version parts',
  #vaVisibility : 'private' }
TonelLoaderGitVersionStrategy class >> githubShortHash [
	"A block which will return the GitHub short version of a full commit hash - 7 characters long"

	^[:hexHashString | hexHashString first: 7]
]

{ #category : 'Defaults - Version parts',
  #vaVisibility : 'private' }
TonelLoaderGitVersionStrategy class >> gitlabShortHash [
	"A block which will return the Gitlab short version of a full commit hash - 8 characters long"
	^[:hexHashString | hexHashString first: 8]
]

{ #category : 'Defaults - Version parts',
  #vaVisibility : 'private' }
TonelLoaderGitVersionStrategy class >> hashAndBranchPattern [
	"Use a version name consisting of git hash and branch.
	
	The version name pattern will be expanded with 3 arguments:
	 1. The commit hash representation
	 2. The branch path representation
	 3. The commit date representation"
	
	^'<1s>-<2s>'
]

{ #category : 'initialization',
  #vaVisibility : 'private' }
TonelLoaderGitVersionStrategy class >> initializeAfterLoad [
	
	DefaultVersionNamePattern :=self hashAndBranchPattern.
	DefaultCommitHashVersionPart := self githubShortHash.
	DefaultBranchPathVersionPart := self onlyBranchName.
	DefaultCommitDateVersionPart := self iso8601Date.
]

{ #category : 'Defaults - Version parts',
  #vaVisibility : 'private' }
TonelLoaderGitVersionStrategy class >> iso8601Date [
	"A block which will return the date in UTC tz in ISO8601 format"
	^[:aDateTime | aDateTime asUTC printString]
	
]

{ #category : 'Defaults - Version parts',
  #vaVisibility : 'private' }
TonelLoaderGitVersionStrategy class >> onlyBranchName [
		"A block which will return only the branch name of the full path to the branch"
	^[:fullGitBranchPath | fullGitBranchPath parts last]
	
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
								commitHash := gitBranchCommitFile nextLine.
								stat := gitBranchPath cfsStat.
								commitDate :=
									DateAndTime date: stat stMtime first time: stat stMtime last]
										ensure: [gitBranchCommitFile close].
							commitHash isEmptyOrNil
								ifTrue: [
									TonelLoaderError signal:
										('Could not retrieve commit hash from the repository')]
								ifFalse: [
									^(self versionNamePattern
										expandMacrosWith: (hashToVersionPart value: commitHash)
										with: (pathToVersionPart value: gitBranchPath)
										with: (dateToVersionPart value: commitDate))]]]
				ifFalse: [
					TonelLoaderError signal: (
						'There is no git repository at <1p>'
							expandMacrosWith: self loader reader repositoryPath)]

			].
	^nil
]

{ #category : 'accessing' }
TonelLoaderGitVersionStrategy >> branchPathToVersionPart: aBlock [
	"Answer a block used to convert the git branch path to a string that can be included in the Tonel version name
	
	Argument
	 <Block returning String> 1 argument, the full path of the git branch"
	pathToVersionPart := aBlock
]

{ #category : 'accessing' }
TonelLoaderGitVersionStrategy >> commitDateToVersionPart: aBlock [
	"Set the block used to convert the commit date into a string that can be included in the Tonel version name
	
	Argument
	 <Block returning String> 1 argument, the commit date of the git branch"
	dateToVersionPart := aBlock
]

{ #category : 'accessing' }
TonelLoaderGitVersionStrategy >> commitHashToVersionPart: aBlock [
	"Set the block used to convert the commit hash into a string that can be included in the Tonel version name
	 
	 Arguments:
	 <Block> 1 argument, the the git commit hashas a hex string
	 "
	hashToVersionPart := aBlock
]

{ #category : 'initialization' }
TonelLoaderGitVersionStrategy >> initialize [
	super initialize.
	versionNamePattern := DefaultVersionNamePattern.
	dateToVersionPart := DefaultCommitDateVersionPart.
	pathToVersionPart := DefaultBranchPathVersionPart.
	hashToVersionPart := DefaultCommitHashVersionPart.
]

{ #category : 'versioning' }
TonelLoaderGitVersionStrategy >> versionFor: aTonelApplication [
	"Answer the version for anAppOrSubapp, 
	 based on the commit id of the source repository."

	^self attemptVersionFromGit
]

{ #category : 'accessing' }
TonelLoaderGitVersionStrategy >> versionNamePattern [
	"The version name pattern will be expanded with 3 arguments:
	 1. The commit hash representation
	 2. The branch path representation
	 3. The commit date representation
	 
	 Answers:
	 <String> Pattern to be expanded into a version name"
	^versionNamePattern 
		ifNil: [versionNamePattern := DefaultVersionNamePattern]
]

{ #category : 'accessing' }
TonelLoaderGitVersionStrategy >> versionNamePattern: aString [
	"The version name pattern will be expanded with 3 arguments:
	 1. The commit hash representation
	 2. The branch path representation
	 3. The commit date representation
	 
	 Answers:
	 <String> Pattern to be expanded into a version name"
	versionNamePattern := aString
]
