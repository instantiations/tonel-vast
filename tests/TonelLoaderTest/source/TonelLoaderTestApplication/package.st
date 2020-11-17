Package {
	#name : 'TonelLoaderTestApplication',
	#vaPrerequisites : ['TonelLoaderTestExtendedApplication'],
	#vaSubApplications : [
	{
		#condition : 'true',
		#subapps : [
			'TonelLoaderTestSubapplicationA'
		]
	}
]
}
