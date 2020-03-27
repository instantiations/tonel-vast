Class {
	#name : 'TonelConfigurationMap',
	#superclass : 'Object',
	#instVars : [
		'name',
		'versionName',
		'loader',
		'applications',
		'conditions',
		'hasChanges',
		'comment'
	],
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'Not categorized' }
TonelConfigurationMap class >> from: aDictionary in: aTonelLoader [

	^self new
		initializeFrom: aDictionary in: aTonelLoader;
		yourself
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelConfigurationMap >> addConfigurationExpression: expression withRequiredMaps: aCollection to: emConfigurationMap [

	emConfigurationMap
		addConfigurationExpression: expression;
		addRequiredMapsAsLast: (
				aCollection collect: [:mapAssoc |
					(EmConfigurationMap editionsFor: mapAssoc key)
						detect: [:one | one versionName = mapAssoc value]
						ifNone: [EmConfigurationMap named: mapAssoc key timeStamp: mapAssoc value]])
			for: expression
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelConfigurationMap >> addPrerequisitesTo: emConfigurationMap [

	self conditions do: [:condition |
		self
			addConfigurationExpression: condition key
			withRequiredMaps: condition value
			to: emConfigurationMap]
]

{ #category : 'accessing' }
TonelConfigurationMap >> applicationNames [

	^self applications collect: [:each | each key ]
]

{ #category : 'accessing' }
TonelConfigurationMap >> applications [
	^applications
]

{ #category : 'accessing' }
TonelConfigurationMap >> applications: aCollection [
	applications := aCollection
]

{ #category : 'accessing' }
TonelConfigurationMap >> comment [
	^comment
]

{ #category : 'accessing' }
TonelConfigurationMap >> comment: aString [
	comment := aString
]

{ #category : 'Initializing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> computeRequiredMapsFrom: aDictionary [

	^aDictionary at: #requiredMaps ifAbsent: [#()]
]

{ #category : 'accessing' }
TonelConfigurationMap >> conditions [
	^conditions
]

{ #category : 'accessing' }
TonelConfigurationMap >> conditions: anObject [
	conditions := anObject
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelConfigurationMap >> createNewEdition [
	
	^EmConfigurationMap create: self name.
	

]

{ #category : 'testing' }
TonelConfigurationMap >> equals: anEmConfigurationMap [

	^anEmConfigurationMap versionName = self versionName and: 
			[(self hasSameConditionsAs: anEmConfigurationMap) and: 
					[(self hasSameApplicationsAs: anEmConfigurationMap) and: 
							[(self hasSameRequiredMapsAs: anEmConfigurationMap) 
								and: [anEmConfigurationMap comment = self comment]]]]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> hasSameApplicationsAs: anEmConfigurationMap [

	| emAppVersions |
	anEmConfigurationMap applicationNames asSortedCollection 
		= self applicationNames asSortedCollection ifFalse: [^false].
	emAppVersions := anEmConfigurationMap shadowApplications 
				collect: [:each | each name -> each versionName].
	(self applications asSortedCollection: [:a :b | a key <= b key]) 
		with: emAppVersions
		do: 
			[:localApp :emApp | 
			(localApp key asSymbol = emApp key asSymbol 
				and: [(self loadedVersionOfAppNamed: localApp) = emApp value]) 
					ifFalse: [^false]].
	^true
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> hasSameConditionsAs: anEmConfigurationMap [

	^anEmConfigurationMap requiredMapsConfigurations size 
		= self conditions size
]

{ #category : 'testing' }
TonelConfigurationMap >> hasSameRequiredMapsAs: anEmConfigurationMap [

	| localPrereqs emPrereqs sortBlock |

	sortBlock := [:a :b | a key <= b key].
	localPrereqs :=
		(self requiredMaps collect: [:each | each name -> each versionName])
			asSortedCollection: sortBlock.
	emPrereqs :=
		(anEmConfigurationMap requiredMaps collect: [:each | each name -> each versionName])
			asSortedCollection: sortBlock.

	^localPrereqs = emPrereqs
]

{ #category : 'Initializing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> initializeFrom: aDictionary in: aTonelLoader [

	loader := aTonelLoader.
	name := aDictionary at: #name.
	conditions := (aDictionary at: #conditions
				ifAbsent: [OrderedCollection new]) collect: 
						[:each | 
						(each at: #condition ifAbsent: ['true']) 
							-> (self computeRequiredMapsFrom: each)].
	applications := aDictionary at: #applications
				ifAbsent: [OrderedCollection new].
	versionName := aDictionary at: #versionName ifAbsent: [String new].
	comment := aDictionary at: #comment ifAbsent: [String new]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> isExpressionValid: anExpression [
		"Private - Return whether the configuration expression
		 anExpression is valid for this image."

		"Note: Cannot reliably test expressions if there is no compiler
		 so always return false."

	| compiler |
	(compiler := System globalNamespace classAt: #Compiler) isNil ifTrue: [^false].
	^true storeString = anExpression or: [
		'System vmType = ', System image vmType storeString = anExpression or: [  "$NON-NLS$"
			(compiler evaluate: anExpression for: (EmEvaluationRedirectionForConfigExpressions new)) == true]]
				"just in case it isn't a boolean expression"
	
]

{ #category : 'loading' }
TonelConfigurationMap >> load [

	| emConfigMapEdition emApps |
	emApps := self loadApplicationsFor: emConfigMapEdition.	
	emConfigMapEdition := self selectOrCreateNewEdition.
	(emConfigMapEdition isVersion)
		ifFalse: [
			emApps do: [:each | emConfigMapEdition addApplication: each].
			self addPrerequisitesTo: emConfigMapEdition.
			self versionEdition: emConfigMapEdition].
	
	self loader loadedConfigurationMaps add: self.
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelConfigurationMap >> loadApplicationsFor: emConfigMap [
	^self loader loadApplicationsNamed: self applicationNames
	
	
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> loadedVersionOfAppNamed: localApp [

	^(Smalltalk classAt: localApp key asSymbol)
		ifNil: [localApp value]
		ifNotNil: [:emApp | emApp versionName]
]

{ #category : 'accessing' }
TonelConfigurationMap >> loader [
	^loader
]

{ #category : 'accessing' }
TonelConfigurationMap >> loader: anObject [
	loader := anObject
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelConfigurationMap >> loadRequiredMaps [
	self requiredMaps do: 
			[:each | 
			(self loader loadedConfigurationMaps includes: each) 
				ifFalse: [each loadWithRequiredMaps]]
]

{ #category : 'loading' }
TonelConfigurationMap >> loadWithRequiredMaps [
	self loadRequiredMaps.
	self load
]

{ #category : 'accessing' }
TonelConfigurationMap >> name [
	^name
]

{ #category : 'accessing' }
TonelConfigurationMap >> name: anObject [
	name := anObject
]

{ #category : 'printing' }
TonelConfigurationMap >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(''';
		nextPutAll: self name;
		space;
		nextPutAll: self versionName asString;
		nextPutAll: ''')'
]

{ #category : 'accessing' }
TonelConfigurationMap >> requiredMaps [

	| requiredMaps |

	requiredMaps := OrderedCollection new.
	self conditions do: [:assoc | | condition configMapsNames |
		condition := assoc key.
		configMapsNames := assoc value.
		(self isExpressionValid: condition)
			ifTrue: [
				requiredMaps addAll: (
					configMapsNames collect: [:each |
						self loader
							configurationMapNamed: each key
							versionName: each value
							ifNone: [(TonelEmConfigurationMap name: each key versionName: each value)
											loader: self loader;
											yourself]])]].
	^requiredMaps
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelConfigurationMap >> selectOrCreateNewEdition [

	self loader alwaysCreateEditions ifTrue: [^self createNewEdition].
	^(EmConfigurationMap editionsFor: self name) detect: [:one | self equals: one ] ifNone: [self createNewEdition]
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelConfigurationMap >> versionEdition: anEmConfigurationMap [

	(anEmConfigurationMap shadowApplications allSatisfy: [:each | each isVersion])
		ifTrue: [anEmConfigurationMap versionName: self versionName]
]

{ #category : 'accessing' }
TonelConfigurationMap >> versionName [
	^versionName
]

{ #category : 'accessing' }
TonelConfigurationMap >> versionName: anObject [
	versionName := anObject
]
