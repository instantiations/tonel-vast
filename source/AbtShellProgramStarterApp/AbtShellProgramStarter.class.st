"
I start commands launched from the shell/command of my host OS.
"
Class {
	#name : 'AbtShellProgramStarter',
	#superclass : 'AbtProgramStarter',
	#instVars : [
		'currentDirectory',
		'stdoutPath'
	],
	#pools : [
		'CfsConstants'
	],
	#category : 'AbtShellProgramStarterApp'
}

{ #category : 'accessing' }
AbtShellProgramStarter >> currentDirectory [
	^currentDirectory
]

{ #category : 'accessing' }
AbtShellProgramStarter >> currentDirectory: aStringOrNil [
	currentDirectory := aStringOrNil
]

{ #category : 'accessing' }
AbtShellProgramStarter >> stdoutPath [
	^stdoutPath
]

{ #category : 'accessing' }
AbtShellProgramStarter >> stdoutPath: anObject [
	stdoutPath := anObject
]
