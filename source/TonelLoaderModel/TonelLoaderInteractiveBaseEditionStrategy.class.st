Class {
	#name : 'TonelLoaderInteractiveBaseEditionStrategy',
	#superclass : 'TonelLoaderBaseEditionStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'operations' }
TonelLoaderInteractiveBaseEditionStrategy >> selectBaseEditionOf: aTonelSubApplication [

	^(CwListPrompter new)
		messageString: (TonelMsg06 bindWith: aTonelSubApplication name);
		items: aTonelSubApplication availableShadows ;
		printBlock: [:ea | TonelMsg07 bindWith: ea signature with: ea timeStamp];
		prompt	"$NLS$ Application %1 exists but is not loaded. Please choose a base version."	"$NLS$ %1 %2"
]

{ #category : 'operations' }
TonelLoaderInteractiveBaseEditionStrategy >> selectPrerequisitesOf: application in: prereqShadows using: browser at: cursorPosition [


	^CwListPrompter new
		messageString:  ( ( NlsCatEMT  residentMsg: 'MxEMT26' )  bindWith: application);
		selectedItems: #();
		items: prereqShadows;
		printBlock:  [:shadow | shadow signature];
		prompt

]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
TonelLoaderInteractiveBaseEditionStrategy >> signalMissingPrerequisiteOf: application [

	^self owningImage 
		message: ((NlsCatEMT residentMsg: 'MxEMT25') bindWith: application)
]
