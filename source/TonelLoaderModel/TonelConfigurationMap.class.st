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

{ #category : 'accessing' }
TonelConfigurationMap >> conditions [
	^conditions
]

{ #category : 'accessing' }
TonelConfigurationMap >> conditions: anObject [
	conditions := anObject
]

{ #category : 'Initializing',
  #vaVisibility : 'private' }
TonelConfigurationMap >> initializeFrom: aDictionary in: aTonelLoader [

	loader := aTonelLoader.
	name := aDictionary at: #name.
	conditions := (aDictionary at: #conditions ifAbsent: [OrderedCollection new]) collect: [:each |
		(each at: #condition ifAbsent: ['true']) -> (each at: #requiredMaps ifAbsent: [#()])
	].
	applications := aDictionary at: #applications ifAbsent: [OrderedCollection new].
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

{ #category : 'Not categorized' }
TonelConfigurationMap >> load [
	
	self loader loadApplicationsNamed: self applicationNames
	
]

{ #category : 'accessing' }
TonelConfigurationMap >> loader [
	^loader
]

{ #category : 'accessing' }
TonelConfigurationMap >> loader: anObject [
	loader := anObject
]

{ #category : 'Not categorized' }
TonelConfigurationMap >> loadWithRequiredMaps [

	self requiredMaps do: [:each |
		(self loader loadedConfigurationMaps includes: each)
			ifFalse: [each loadWithRequiredMaps]].
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
							ifNone: [TonelEmConfigurationMap name: each key versionName: each value]])]].
	^requiredMaps
]

{ #category : 'accessing' }
TonelConfigurationMap >> versionName [
	^versionName
]

{ #category : 'accessing' }
TonelConfigurationMap >> versionName: anObject [
	versionName := anObject
]
