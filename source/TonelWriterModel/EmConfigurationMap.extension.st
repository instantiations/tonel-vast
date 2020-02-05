Extension {
	#name : 'EmConfigurationMap'
}

{ #category : '*TonelWriterModel',
 #vaCategories : ['Not categorized'] }
EmConfigurationMap >> fileName [

	^'<1s>.configmap.st' expandMacrosWith: self name
]
