Class {
	#name : 'TonelWriterApplicationDefinition',
	#superclass : 'Object',
	#instVars : [
		'application'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Instance creation' }
TonelWriterApplicationDefinition class >> for: anApplication [

	^self new initializeFor: anApplication
]

{ #category : 'Accessing' }
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

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelWriterApplicationDefinition >> classDefinitionsFromClassesDefinedIn: anApplication [

	^anApplication defined
		collect: [:class | TonelWriterClassDefinition of: class definedIn: anApplication]
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelWriterApplicationDefinition >> classDefinitionsOfDefinedClasses [

	^self classDefinitionsFromClassesDefinedIn: application
]

{ #category : 'Accessing' }
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

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelWriterApplicationDefinition >> initializeFor: anApplication [

	application := anApplication
]

{ #category : 'Accessing' }
TonelWriterApplicationDefinition >> tonelPackageName [

	^(application respondsTo: #_TONEL_packageName)
		ifTrue: [application _TONEL_packageName]
		ifFalse: [application name asString]
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
