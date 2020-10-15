Class {
	#name : 'EmApplicationsRemovalOperation',
	#superclass : 'EmApplicationsOperation',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'accessing' }
EmApplicationsRemovalOperation >> applications [

	^(self events collect: [:each | Smalltalk classAt: each identifier]) asSet
]

{ #category : 'operations' }
EmApplicationsRemovalOperation >> executeFor: anEmChangelog purge: aBoolean [

	"Executes the removal of receiver."

	EmClassDevelopment imageBuilder removeApplications: self applications.
	aBoolean ifTrue: [self purge]
]

{ #category : 'operations',
  #vaVisibility : 'private' }
EmApplicationsRemovalOperation >> purge [
	self events do:
		[:ev | 
			ev partsRecordClass purge: ev identifier at: ev timeStamp.
			ev isApplication 
				ifTrue: 
					[EmLibraryCache current flushEntriesForApplicationNamed: ev identifier]
				ifFalse: 
					[EmLibraryCache current flushEntriesForSubApplicationNamed: ev identifier]]
]
