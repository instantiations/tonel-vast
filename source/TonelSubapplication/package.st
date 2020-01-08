Package {
	#name : 'TonelSubapplication',
	#vaParent : 'TonelWriterTests',
	#vaSubApplications : [
	{
		#condition : '(Smalltalk at: #\'TonelExampleConfExp\' ifAbsentPut: [true] ) == false',
		#subapps : [
			'TonelWriterTestShadowSubSubApp'
		]
	},
	{
		#condition : 'true',
		#subapps : [
			'TonelWriterTestSubSubApp'
		]
	}
]
}
