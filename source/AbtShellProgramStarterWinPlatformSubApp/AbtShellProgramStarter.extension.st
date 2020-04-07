Extension {
	#name : 'AbtShellProgramStarter'
}

{ #category : '*AbtShellProgramStarterWinPlatformSubApp',
 #vaCategories : ['AbtRun-API'] }
AbtShellProgramStarter >> startProgram [
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

	(startUpInfo := OSStartupinfo new)
		dwFlags: StartfUseshowwindow;
		wShowWindow: SwHide.

	rc :=
		OS
			createProcess: nil
			lpszCommandLine: cmdLine
			lpsaProcess: Null
			lpsaThread: Null
			fInheritHandles: false
			fdwCreate: CreateNoWindow
			lpvEnvironment: Null
			lpszCurDir: self currentDirectory
			lpsiStartInfo: startUpInfo
			lppiProcInfo: (processInformation := OSProcessInformation new).

	self lastError: (
		rc
			ifTrue: [
				processInformation hProcess closeHandle.
				processInformation hThread closeHandle.
				0]
			ifFalse: [OS getLastError]).
	^rc
]
