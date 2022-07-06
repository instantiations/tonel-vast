Extension {
	#name : 'EmConfigurationMap'
}

{ #category : 'testing' }
EmConfigurationMap >> areApplicationsInTheImage [
	"Answer whether all the receiver's applications are loaded
		 regardless of the version."

	| appEditions |

	(appEditions := self applicationEditions) isEmpty ifTrue: [^false].
	appEditions associationsDo: [:assoc | | app |
		app := System image globalNamespace at: assoc key asSymbol ifAbsent: [^false].
		(System image loadedApplications includes: app) ifFalse: [^false]].
	^true
]

{ #category : 'accessing' }
EmConfigurationMap >> fileName [

	^'<1s>.configmap.st' expandMacrosWith: self name
]
