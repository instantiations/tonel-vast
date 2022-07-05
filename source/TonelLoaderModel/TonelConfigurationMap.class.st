"

DESCRIPTION:
An instance of the TonelConfigurationMap class provides an object 
that represents an ENVY Library Configuration Map (EmConfigurationMap)
within a Tonel formatted source.

When instances of receiver specify its required maps, they could be other 
instances of TonelConfigurationMap or instances of TonelEmConfigurationMap.

RESPONSIBILITY:
- Reify the serialized config map in a Tonel formatted repository.
- Load itself and its required maps
"
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
		'comment',
		'version',
		'timeStamp',
		'emConfigMapEdition'
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
		addRequiredMapsAsLast: (aCollection 
					collect: [:reqMap | self selectPrerequisiteEditionFor: reqMap])
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

	^self applications collect: [:each | each name ]
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
TonelConfigurationMap >> computeApplicationsFrom: aDictionary [

	^(aDictionary at: #applications ifAbsent: [OrderedCollection new]) collect: [:each | self computeReferenceFrom: each]
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> computeReferenceFrom: anObject [
	"Computes a reference from anObject.
	 anObject can be either anAssociation (v1.0) or aDictionary (v1.1)."

	| reference |

	reference :=
		TonelConfigurationMapReference from: (
			anObject isDictionary
				ifTrue: [anObject]
				ifFalse: [
					(Dictionary
						with: #name -> anObject key
						with: #versionName -> anObject value
						with: #ts -> 0)]).
	^reference
]

{ #category : 'Initializing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> computeRequiredMapsFrom: aDictionary [

	^(aDictionary at: #requiredMaps ifAbsent: [Array new])
		collect: [:each | self computeReferenceFrom: each]
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

	| editionsDict newTS aConfigMap |

	aConfigMap := EmConfigurationMap named: self name timeStampWithVersionInfo: self timeStamp.
	EmConfigurationMap configurationRecordClass relocateRootDictionaryUsing: [:diskDict |
		diskDict
			at: aConfigMap name
			putPointerFrom: [:editionsFP |
				editionsDict := EmEditionsDictionary updating: editionsFP from: diskDict library.
				newTS :=
					(editionsDict includesKey: self timeStamp)
						ifTrue: [editionsDict nextTimeStamp]
						ifFalse: [aConfigMap timeStamp].
				editionsDict
					at: newTS
					putPointerFrom: [:ignored | | editionRecord |
						editionRecord := (EmConfigurationMap configurationRecordClass
							using: (editionsDict at: aConfigMap timeStamp)
							from: diskDict library).
						editionRecord isVersion
							ifFalse: [
								editionRecord := (EmConfigurationMap configurationRecordClass
									using: EmLibraryPointer void
									from: diskDict library)].
						editionRecord map: aConfigMap.
						editionRecord
							newEditionAt: newTS using: Dictionary new ifUnable: [^nil];
							insert]]].
	^aConfigMap


]

{ #category : 'Initializing' }
TonelConfigurationMap >> defaultFormatVersion [
	^'1.0'
]

{ #category : 'accessing' }
TonelConfigurationMap >> emConfigMapEdition [
	^emConfigMapEdition
]

{ #category : 'accessing' }
TonelConfigurationMap >> emConfigMapEdition: anObject [
	emConfigMapEdition := anObject
]

{ #category : 'testing' }
TonelConfigurationMap >> equals: anEmConfigurationMap [

	^(self hasSameVersionAs: anEmConfigurationMap) and: 
			[(self hasSameConditionsAs: anEmConfigurationMap) and: 
					[(self hasSameApplicationsAs: anEmConfigurationMap) and: 
							[(self hasSameRequiredMapsAs: anEmConfigurationMap) 
								and: [anEmConfigurationMap comment = self comment]]]]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> hasSameApplicationsAs: anEmConfigurationMap [

	anEmConfigurationMap applicationNames asSortedCollection 
		= self applicationNames asSortedCollection ifFalse: [^false].
	(self applications asSortedCollection: [:a :b | a name <= b name]) asArray 
		with: anEmConfigurationMap shadowApplications
		do: 
			[:cmApp :emApp | 
			(cmApp name asSymbol = emApp name asSymbol and: 
					[(self loadedTimeStampOfAppNamed: cmApp) = emApp timeStamp 
						or: [(self loadedVersionOfAppNamed: cmApp) = emApp versionName]]) 
				ifFalse: [^false]].
	^true
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> hasSameConditionsAs: anEmConfigurationMap [

	^anEmConfigurationMap requiredMapsConfigurations size 
		= self conditions size
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> hasSameRequiredMapsAs: anEmConfigurationMap [

	| localPrereqs emPrereqs sortBlock |

	sortBlock := [:a :b | a key <= b key].
	localPrereqs :=
		(self requiredMaps collect: [:each | (each name) -> (each timeStamp)])
			asSortedCollection: sortBlock.
	emPrereqs :=
		(anEmConfigurationMap requiredMaps collect: [:each | (each name) -> (each timeStamp)])
			asSortedCollection: sortBlock.

	^localPrereqs = emPrereqs
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> hasSameVersionAs: anEmConfigurationMap [

	^anEmConfigurationMap timeStamp = self timeStamp
]

{ #category : 'Initializing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> initializeFrom: aDictionary in: aTonelLoader [

	version := aDictionary at: #formatVersion
				ifAbsent: [self defaultFormatVersion].
	loader := aTonelLoader.
	name := aDictionary at: #name.
	conditions := (aDictionary at: #conditions
				ifAbsent: [OrderedCollection new]) collect: 
						[:each | 
						(each at: #condition ifAbsent: ['true']) 
							-> (self computeRequiredMapsFrom: each)].
	applications := self computeApplicationsFrom: aDictionary.
	versionName := aDictionary at: #versionName ifAbsent: [String new].
	timeStamp := EmTimeStamp new: (aDictionary at: #ts ifAbsent: [0]).
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

{ #category : 'testing' }
TonelConfigurationMap >> isReference [
	"Answer whether receiver represents a reference to an actual EmConfigurationMap.
	 Receiver is a Tonel config map, not a reference, so always return false."

	^false
]

{ #category : 'loading' }
TonelConfigurationMap >> load [
	| emApps |
	emApps := self loadApplications.
	emConfigMapEdition := self selectOrCreateNewEdition.
	emConfigMapEdition isVersion 
		ifFalse: 
			[emApps do: [:each | emConfigMapEdition addApplication: each].
			self addPrerequisitesTo: emConfigMapEdition.
			self versionEdition: emConfigMapEdition].
	self loader loadedConfigurationMaps add: self
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelConfigurationMap >> loadApplications [
	^self loader loadApplicationsNamed: self applicationNames
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> loadedTimeStampOfAppNamed: cmApp [

	^(Smalltalk classAt: cmApp name asSymbol)
		ifNil: [cmApp timeStamp]
		ifNotNil: [:emApp | emApp timeStamp]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> loadedVersionOfAppNamed: cmApp [

	^(Smalltalk classAt: cmApp name asSymbol)
		ifNil: [cmApp versionName]
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
TonelConfigurationMap >> loadRequiredMaps: aBoolean [
	"Load the required maps of receiver if aBoolean is true, if it was not
	 loaded yet.
	 If the required map is another TonelConfigurationMap, load it
	 regardless of whether aBoolean is true."

	self requiredMaps do: [:each |
		((self loader loadedConfigurationMaps includes: each) not
			and: [each isReference not or: [aBoolean & each isReference]])
				ifTrue: [each loadWithRequiredMaps]]
]

{ #category : 'loading' }
TonelConfigurationMap >> loadWithRequiredMaps [
	"Load the receiver and all its required maps first.
	Loading a required map may in turn load other required maps."

	self loadWithRequiredMaps: true
]

{ #category : 'loading' }
TonelConfigurationMap >> loadWithRequiredMaps: aBoolean [
	"Load the receiver. And all its required maps first if aBoolean is true.
	Loading a required map may in turn load other required maps."

	self loadRequiredMaps: aBoolean.
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
	"Prints a textual representation of receiver on aStream."

	super printOn: aStream.
	aStream
		nextPutAll: '(''';
		nextPutAll: self name.

	self versionName notEmpty
		ifTrue: [
			aStream
				space;
				nextPutAll: self versionName asString].
	aStream nextPutAll: ''')'
]

{ #category : 'accessing' }
TonelConfigurationMap >> requiredMaps [

	| requiredMaps |

	requiredMaps := OrderedCollection new.
	self conditions do: [:assoc | | condition conditionMaps |
		condition := assoc key.
		conditionMaps := assoc value.
		(self isExpressionValid: condition)
			ifTrue: [
				requiredMaps addAll: (
					conditionMaps collect: [:each |
						self loader
							configurationMapNamed: each name
							ts: each timeStamp
							versionName: each versionName])]].
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
TonelConfigurationMap >> selectPrerequisiteEditionFor: reqMap [

	| loadedConfigMap |
	loadedConfigMap := (self loader 
				configurationMapNamed: reqMap name
				ts: reqMap timeStamp
				versionName: reqMap versionName
				ifNone: [nil]) 
					ifNotNil: [:tonelConfigMap | tonelConfigMap emConfigMapEdition].
	^loadedConfigMap ifNil: [self loader configMapResolver resolveReference: reqMap]
]

{ #category : 'accessing' }
TonelConfigurationMap >> timeStamp [
	^timeStamp ifNil: [EmTimeStamp new: 0]
]

{ #category : 'accessing' }
TonelConfigurationMap >> timeStamp: anObject [
	timeStamp := anObject
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
