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
	#category : 'TonelLoaderModel'
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
	 answer false.
	 NOTE: This will be replaced with the unified OSProcess in VAST 10."

	| os |
	os := (System image subsystemType: 'OS').
	os = 'WIN32s' ifTrue: [^self startWindowsProgram].
	os = 'UNIX' ifTrue: [^self startUnixProgram].
	self error: 'Unsupported platform'
]

{ #category : 'starting',
  #vaVisibility : 'private' }
AbtShellProgramStarter >> startUnixProgram [
	"Start the receiver's program.  If the program cannot be started,
	 answer false."

	| input cmdLine  |
	(self programName == nil or: [self programName = '']) ifTrue: [^false].
	currentDirectory notNil 
		ifTrue: [cmdLine := 'cd ', currentDirectory, ' && ', self programName] 
		ifFalse: [cmdLine := self programName].
	((input := self programInput) == nil or: [input = '']) ifFalse: [
		cmdLine := cmdLine , ' ' , input.
		self stdoutPath isEmptyOrNil ifFalse: [
			cmdLine := cmdLine, ' > ', self stdoutPath
		]
	].
	^(Smalltalk classAt: #UNIXProcess) shell: cmdLine
]

{ #category : 'starting',
  #vaVisibility : 'private' }
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
