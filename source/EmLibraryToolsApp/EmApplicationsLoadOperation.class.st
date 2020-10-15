Class {
	#name : 'EmApplicationsLoadOperation',
	#superclass : 'EmApplicationsOperation',
	#category : 'EmLibraryToolsApp'
}

{ #category : 'Not categorized' }
EmApplicationsLoadOperation >> applications [

	| apps |

	apps := Set new.
	self events do: [:each |
		apps addAll: (
			(Application shadowsFor: each identifier)
				select: [:shadow | shadow timeStamp = each timeStamp])].
	^apps
]

{ #category : 'Not categorized' }
EmApplicationsLoadOperation >> executeFor: anEmChangelog purge: aBoolean [


	EmClassDevelopment imageBuilder loadApplications: self applications.
	
]
