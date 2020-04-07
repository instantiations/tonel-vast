Package {
	#name : 'AbtShellProgramStarterApp',
	#vaPrerequisites : ['AbtRunProgramStarterApp'],
	#vaSubApplications : [
	{
		#condition : '\'WIN32s\'  = (System image subsystemType: \'OS\')',
		#subapps : [
			'AbtShellProgramStarterWinPlatformSubApp'
		]
	}
]
}
