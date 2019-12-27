Class {
	#name : 'TonelLoaderInteractiveBaseEditionStrategy',
	#superclass : 'TonelLoaderBaseEditionStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderInteractiveBaseEditionStrategy >> confirmLoadPrerequisites: prereqNames of: applicationNames using: browser [

	^browser owningImage 
		confirm: ((NlsCatEMT residentMsg: 'MxEMT24') addLineDelimiters 
				bindWith: applicationNames
				with: prereqNames)
]

{ #category : 'operations' }
TonelLoaderInteractiveBaseEditionStrategy >> selectBaseEditionOf: aTonelSubApplication [

	^(CwListPrompter new)
		messageString: (TonelMsg06 bindWith: aTonelSubApplication name);
		items: aTonelSubApplication;
		printBlock: [:ea | TonelMsg07 bindWith: ea signature with: ea timeStamp];
		prompt	"$NLS$ Application %1 exists but is not loaded. Please choose a base version."	"$NLS$ %1 %2"
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderInteractiveBaseEditionStrategy >> signalMissingPrerequisiteOf: application [

	^self owningImage 
		message: ((NlsCatEMT residentMsg: 'MxEMT25') bindWith: application)
]
