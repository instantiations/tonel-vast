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

{ #category : 'AbtRun-API' }
AbtShellProgramStarter >> startProgram [
	"Start the receiver's program.  If the program cannot be started,
	 answer false."

	^(System image subsystemType: 'OS') = 'WIN32s'
		ifTrue: [self startWindowsProgram]
		ifFalse: [self startUnixProgram]
]

{ #category : 'Not categorized' }
AbtShellProgramStarter >> startWindowsProgram [
	"Start the receiver's program.  If the program cannot be started,
	 answer false."

	| input cmdLine rc startUpInfo processInformation  |

	(self programName == nil or: [self programName = '']) ifTrue: [^false].
	cmdLine := 'cmd /c ',  self programName.
	((input := self programInput) == nil or: [input = '']) ifFalse: [
		cmdLine := cmdLine , ' ' , input.
		self stdoutPath isEmptyOrNil ifFalse: [
			cmdLine := cmdLine, ' > ', self stdoutPath
		]
	].

	(startUpInfo := (Smalltalk classAt: #OSStartupinfo) new)
		dwFlags: (PlatformConstants at: 'StartfUseshowwindow');
		wShowWindow: (PlatformConstants at: 'SwHide').

	rc := (PlatformGlobals at: 'OS')
		 	createProcess: nil
			lpszCommandLine: cmdLine
			lpsaProcess: 0
			lpsaThread: 0
			fInheritHandles: false
			fdwCreate: (PlatformConstants at:'CreateNoWindow')
			lpvEnvironment: 0
			lpszCurDir: self currentDirectory
			lpsiStartInfo: startUpInfo
			lppiProcInfo: (processInformation := (Smalltalk classAt: #OSProcessInformation) new).

	self lastError: (
		rc
			ifTrue: [
				processInformation hProcess closeHandle.
				processInformation hThread closeHandle.
				0]
			ifFalse: [(Smalltalk classAt: #OS) getLastError]).
	^rc
]

{ #category : 'accessing' }
AbtShellProgramStarter >> stdoutPath [
	^stdoutPath
]

{ #category : 'accessing' }
AbtShellProgramStarter >> stdoutPath: anObject [
	stdoutPath := anObject
]
