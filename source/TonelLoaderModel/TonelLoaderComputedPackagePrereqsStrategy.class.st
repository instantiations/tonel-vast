Class {
	#name : 'TonelLoaderComputedPackagePrereqsStrategy',
	#superclass : 'TonelLoaderPackagePrereqsStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'api' }
TonelLoaderComputedPackagePrereqsStrategy >> prerequisitesFor: aTonelApplication [
	"Answer a collection of TonelApplications that are the prerequistes of aTonelApplication
	 based on the computation of dependencies of classes and methods that reference classes 
	 defined in other TonelApplications."

	| needed |
	needed := Set new.
	aTonelApplication withAllSubApplications do: [:app |
		app tonelDefinedClasses do: [:tonelClassDefinition |
			(self loader tonelClassNamed: tonelClassDefinition superclassIdentifier)
				ifNotNil: [:itsSuper | needed add: (self loader rootApplicationOfClass: itsSuper)]].
		app tonelExtendedClasses do: [:tonelExtendedClass |
			(self loader rootApplicationOfClassExtension: tonelExtendedClass)
				ifNotNil: [:itsSuper | needed add: itsSuper]].
		(app tonelDefinedClasses , app tonelExtendedClasses) asArray do: [:tonelClass |
			tonelClass tonelMethods do: [:cm |
				(cm referencedTonelClasses: self loader) do: [:referencedClass |
					needed add: (self loader rootApplicationOfClass: referencedClass)]]]].
	needed remove: aTonelApplication ifAbsent: [].
	needed copy do: [:app | app allPrerequisites do: [:prereq | needed remove: prereq ifAbsent: []]].
	^self filterPrerequisites: needed
]
