Class {
	#name : 'TonelLoaderApplicationPrereqStrategy',
	#superclass : 'TonelLoaderStrategy',
	#category : 'TonelLoaderModel'
}

{ #category : 'api' }
TonelLoaderApplicationPrereqStrategy >> addPrerequisite: emApplication to: tonelApplication [
	"Add emApplication as a prerequisite to tonelApplication."

	tonelApplication addPrerequisite: emApplication
]

{ #category : 'api' }
TonelLoaderApplicationPrereqStrategy >> concretePrerequisitesOf: aTonelApplication [

 
	self subclassResponsibility
]

{ #category : 'testing' }
TonelLoaderApplicationPrereqStrategy >> fixesMismatchs [

	^false
]

{ #category : 'api' }
TonelLoaderApplicationPrereqStrategy >> prerequisitesFor: tonelApplication current: aCollection [

	self subclassResponsibility
]

{ #category : 'api' }
TonelLoaderApplicationPrereqStrategy >> reducePrerequisitesOf: tonelApplication current: currentPrereqs [

	| requiredPrereqs allRequired anApp |

	anApp := tonelApplication emApplication.
	requiredPrereqs := EmInterface current requiredDependentApplicationsIncludingReferencesFor: anApp.
	allRequired := Set new.
	currentPrereqs do: [:each | allRequired addAll: each withAllPrerequisites].
	requiredPrereqs do: [:each |
		((allRequired includes: each) not and: [self fixesMismatchs])
			ifTrue: [
				allRequired addAll: (
					self
						requiredDependentApplicationsIncludingReferencesFor: anApp
						reportInApps: (Array with: each))]].

	currentPrereqs do: [:r | (requiredPrereqs includes: r) ifFalse: [allRequired remove: r]].
	^allRequired
]

{ #category : 'lookup',
  #vaVisibility : 'private' }
TonelLoaderApplicationPrereqStrategy >> requiredDependentApplicationsIncludingReferencesFor: theApplication reportInApps: queryApps [
	"Return the collection of applications that must be prerequisites
	 of theApplication. Required prerequisites are:

		1. All applications that control definitions of the superclasses
		of classes DEFINED in theApplication and its subapplications.

		2. All applications that control definitions of the classes
		EXTENDED in theApplication and its subapplications.

		3. All applications that control definitions of classes REFERENCED
		in any methods controlled by theApplication and its subapplications.
		This includes classes directly and indirectly referenced.

	The collection returned will be the minimum set required (ie
	inherited prerequisites are removed from the collection)."

	| needed itsSuper |

	needed := Set new.

	theApplication withAllSubApplications do: [:app |
		app defined do: [:cl |
			(itsSuper := cl superclass) isNil
				ifFalse: [
					(queryApps includes: itsSuper controller rootApplication)
						ifTrue: [
							"$NLS$ %1 is required due to subclass %2 of %3"
							needed add: itsSuper controller rootApplication]]].
		app extended do: [:cl |
			(queryApps includes: cl controller rootApplication)
				ifTrue: [
					"$NLS$ %1 is required due to class extension of %2"
					needed add: cl controller rootApplication]].
		app defined , app extended asArray do: [:cl |
			(cl class methodsIn: app) , (cl methodsIn: app) do: [:cm |
				cm referencedClasses do: [:referencedCl |
					(queryApps includes: referencedCl controller rootApplication)
						ifTrue: [
							"$NLS$ %1 is required due to referenced class %2 from %3"
							needed add: referencedCl controller rootApplication]]]]].
	needed remove: theApplication ifAbsent: [].
	needed copy do: [:app | app allPrerequisites do: [:prereq | needed remove: prereq ifAbsent: []]].
	^needed
]
