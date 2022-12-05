Class {
	#name : 'TonelWriterApplicationDefinition',
	#superclass : 'Object',
	#instVars : [
		'application',
		'tonelPackageName'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Instance creation' }
TonelWriterApplicationDefinition class >> for: anApplication [

	^self new initializeFor: anApplication
]

{ #category : 'accessing' }
TonelWriterApplicationDefinition >> allPossibleDirectSubApplications [

	| confExpressions allApps |

	confExpressions := application allConfigurationExpressions.
	allApps := Set new.
	confExpressions do: [:each | | dict |
		dict := application releasedSubApplicationsFor: each.
		dict keysAndValuesDo: [:name :timeStamp | | app |
			app :=
				(SubApplication shadowClass named: name timeStamp: timeStamp)
					parent: application;
					loadParts;
					yourself.
			app :=
				app residentApplication notNil
					ifTrue: [allApps add: app residentApplication]
					ifFalse: [
						"app defined do: [:aShadowClass | | definitionRecord |
							definitionRecord := aShadowClass definitionRecord.
							(aShadowClass name = #TonelExampleSubAppClass) ifTrue: [self halt].
							]."
						allApps add: app]]].
	^allApps
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterApplicationDefinition >> classDefinitionsFromClassesDefinedIn: anApplication [

	^anApplication defined 
		collect: [:class | self createClassDefinitionFor: class definedIn: anApplication]
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelWriterApplicationDefinition >> classDefinitionsOfDefinedClasses [

	^self classDefinitionsFromClassesDefinedIn: application
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelWriterApplicationDefinition >> computeTonelPackageName [
	^(application respondsTo: #_TONEL_packageName) 
		ifTrue: [application _TONEL_packageName]
		ifFalse: [self computeTonelPackageNameFromAppName]
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelWriterApplicationDefinition >> computeTonelPackageNameFromAppName [
	^application name asString
]

{ #category : 'accessing' }
TonelWriterApplicationDefinition >> createClassDefinitionFor: class definedIn: anApplication [

	^(TonelWriterClassDefinition of: class definedIn: anApplication)
		packageName: self tonelPackageName;
		yourself
]

{ #category : 'accessing' }
TonelWriterApplicationDefinition >> definedApplication [

	^application 
]

{ #category : 'Defaults' }
TonelWriterApplicationDefinition >> hasDefaultParent [

	^ application isApplication
]

{ #category : 'Defaults' }
TonelWriterApplicationDefinition >> hasDefaultPrerequisites [

	| prereqs |

	prereqs := application prerequisiteNames.
	^prereqs size = 1 and: [prereqs first = 'Kernel']
]

{ #category : 'Defaults' }
TonelWriterApplicationDefinition >> hasDefaultSubApps [

	| confExpressions subapps |

	confExpressions := application allConfigurationExpressions.
	confExpressions size > 1 ifTrue: [^false].
	subapps := (application releasedSubApplicationsFor: confExpressions first) keys.
	^confExpressions first = 'true' and: [subapps isEmpty]
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelWriterApplicationDefinition >> initializeFor: anApplication [

	application := anApplication
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelWriterApplicationDefinition >> setPackageNameFromAppName [
	"Sets receiver package name from receiver app name."

	tonelPackageName := self computeTonelPackageNameFromAppName
]

{ #category : 'accessing' }
TonelWriterApplicationDefinition >> tonelPackageName [

	^tonelPackageName ifNil: [tonelPackageName := self computeTonelPackageName]
]

{ #category : 'Enumerating' }
TonelWriterApplicationDefinition >> withDefinitionsOfDefinedClassesDo: aBlock [

	self classDefinitionsOfDefinedClasses do: [:classDefition | aBlock value: classDefition]
]

{ #category : 'Enumerating' }
TonelWriterApplicationDefinition >> withDefinitionsOfExtendedClassesDo: aBlock [

	application extended do: [:classExtension |
		aBlock value: (TonelWriterClassExtensionDefinition of: classExtension extendedIn: application)]
]

{ #category : 'Enumerating' }
TonelWriterApplicationDefinition >> withPoolPragmaMethodsDo: aBlock [

	| enumeratingBlock |

	enumeratingBlock := [:methodDefinition |
		methodDefinition isPoolPragma ifTrue: [aBlock value: methodDefinition]].
	self withDefinitionsOfDefinedClassesDo: [:aClassDefinition |
		aClassDefinition withClassMethodDefinitionsDo: enumeratingBlock.
		aClassDefinition withInstanceMethodDefinitionsDo: enumeratingBlock].
	self withDefinitionsOfExtendedClassesDo: [:aClassDefinition |
		aClassDefinition withClassMethodDefinitionsDo: enumeratingBlock.
		aClassDefinition withInstanceMethodDefinitionsDo: enumeratingBlock]



]
