Class {
	#name : 'TonelLoaderSettings',
	#superclass : 'Object',
	#instVars : [
		'appSuperGroupSetting',
		'compilerWarningLevel',
		'defaultAppNameSuffix',
		'strategies'
	],
	#classVars : [
		'Default'
	],
	#category : 'TonelLoaderModel'
}

{ #category : 'accessing' }
TonelLoaderSettings class >> default [

	^Default ifNil: [Default := self new]
]

{ #category : 'instance creation' }
TonelLoaderSettings class >> new [

	^super new initialize
]

{ #category : 'private',
  #vaVisibility : 'private' }
TonelLoaderSettings class >> reset [

	Default := nil
]

{ #category : 'permissions' }
TonelLoaderSettings >> appSuperGroupSetting [
	"Read comment of appSuperGroupSetting:"
	
	^ appSuperGroupSetting ifNil: [ appSuperGroupSetting := self defaultAppSuperGroupSetting ]
]

{ #category : 'permissions' }
TonelLoaderSettings >> appSuperGroupSetting: superGroup [
	"Allows the user to specify the 'Super Group' setting to be used for the created applications and subapplications
	by the TonelLoader. The default will be #none. 

	Arguments:
		superGroup - <Symbol> Possible values are #none, #world and #group.
	 "
	appSuperGroupSetting := superGroup
]

{ #category : 'strategies' }
TonelLoaderSettings >> baseEditionStrategy [

	^self strategyAt: #baseEdition ifAbsentPut: [TonelLoaderLatestBaseEditionStrategy new]
]

{ #category : 'strategies' }
TonelLoaderSettings >> baseEditionStrategy: aTonelLoaderStrategy [

	self strategyAt: #baseEdition put: aTonelLoaderStrategy
]

{ #category : 'compiling' }
TonelLoaderSettings >> compilerWarningLevel [
	 "Read comment of compilerWarningLevel:"
	 
	^ compilerWarningLevel ifNil: [ compilerWarningLevel := self defaultCompilerWarningLevel ]
]

{ #category : 'compiling' }
TonelLoaderSettings >> compilerWarningLevel: aLevel [
	"Allows the user to specify the compiler warning level used while TonelLoader compiles 
	 the new methods. When we are importing code, we want to get our code in VA as soon as possible.
	 Therefore, the default is the less restrictive level (level 0) rather than the current one. Once the
	 import finishes, the warning is rollbacked to the previous level. For mode details, read comment in
	 EsCompiler >>#defaultWarningLevel.
	 
	Arguments:
		aLevel - <Number> Possible values are from 0 to 3. 
	 "
	compilerWarningLevel := aLevel
]

{ #category : 'copying' }
TonelLoaderSettings >> copyFor: aTonelLoader [

	| copy |
	self ensureStrategies.
	copy := self copy.
	self strategies keysAndValuesDo: [:key :strategy |
		copy strategyAt: key put: (strategy copyFor: aTonelLoader)].
	^copy
]

{ #category : 'defaults' }
TonelLoaderSettings >> defaultAppNameSuffix [
		
	^defaultAppNameSuffix
]

{ #category : 'naming' }
TonelLoaderSettings >> defaultAppNameSuffix: aStringOrNil [
	"Sets the default app name suffix used by naming strategies."
		
	defaultAppNameSuffix := aStringOrNil
]

{ #category : 'defaults' }
TonelLoaderSettings >> defaultAppSuperGroupSetting [
	
	^ #none
]

{ #category : 'defaults' }
TonelLoaderSettings >> defaultCompilerWarningLevel [
	
	^ 0
]

{ #category : 'accessing' }
TonelLoaderSettings >> ensureStrategies [

	self namingStrategy.
	self baseEditionStrategy.
	self prerequisitesStrategy.
	self versionStrategy.
	
]

{ #category : 'initializing',
  #vaVisibility : 'private' }
TonelLoaderSettings >> initialize [

	super initialize.
	strategies := Dictionary new.
]

{ #category : 'strategies' }
TonelLoaderSettings >> namingStrategy [

	^self strategyAt: #naming ifAbsentPut: [TonelLoaderDefaultNamingStrategy new]
]

{ #category : 'strategies' }
TonelLoaderSettings >> namingStrategy: aTonelLoaderStrategy [

	self strategyAt: #naming put: aTonelLoaderStrategy
]

{ #category : 'copying' }
TonelLoaderSettings >> postCopy [

	strategies := strategies copy.
]

{ #category : 'strategies' }
TonelLoaderSettings >> prerequisitesStrategy [

	^self strategyAt: #prerequisites ifAbsentPut: [TonelLoaderComputedPrerequisitesStrategy new]
]

{ #category : 'strategies' }
TonelLoaderSettings >> prerequisitesStrategy: aTonelLoaderStrategy [

	self strategyAt: #prerequisites put: aTonelLoaderStrategy
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelLoaderSettings >> strategies [

	^strategies
]

{ #category : 'strategies',
  #vaVisibility : 'private' }
TonelLoaderSettings >> strategyAt: aSymbol [

	^self strategies at: aSymbol
]

{ #category : 'strategies',
  #vaVisibility : 'private' }
TonelLoaderSettings >> strategyAt: aSymbol ifAbsent: aBlock [

	^self strategies at: aSymbol ifAbsent: aBlock
]

{ #category : 'strategies',
  #vaVisibility : 'private' }
TonelLoaderSettings >> strategyAt: aSymbol ifAbsentPut: anObject [

	^self strategies at: aSymbol ifAbsentPut: anObject
]

{ #category : 'strategies',
  #vaVisibility : 'private' }
TonelLoaderSettings >> strategyAt: aSymbol put: anObject [

	^self strategies at: aSymbol put: anObject
]

{ #category : 'strategies' }
TonelLoaderSettings >> versionStrategy [

	^self strategyAt: #version ifAbsentPut: [TonelLoaderNoVersionStrategy new]
]

{ #category : 'strategies' }
TonelLoaderSettings >> versionStrategy: aTonelLoaderStrategy [

	self strategyAt: #version put:  aTonelLoaderStrategy
]
