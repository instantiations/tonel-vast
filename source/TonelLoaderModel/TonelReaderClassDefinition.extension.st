Extension {
	#name : 'TonelReaderClassDefinition'
}

{ #category : 'Initialize-Release' }
TonelReaderClassDefinition class >> appNamed: aString [
	
	^ (self
		name: aString 
		superclass: 'Application'   "$NON-NLS$"
		variable: false
		fieldType: 'pointers'  "$NON-NLS$"
		instanceVariables: ''   "$NON-NLS$"
		classVariables: ''   "$NON-NLS$"
		poolDictionaries: '')  "$NON-NLS$"
			addSubAppMethods;
			yourself
]

{ #category : 'Initialize-Release' }
TonelReaderClassDefinition class >> subAppNamed: aString [
	
	^ (self
		name: aString 
		superclass: 'SubApplication'   "$NON-NLS$"
		variable: false
		fieldType: 'pointers'  "$NON-NLS$"
		instanceVariables: ''   "$NON-NLS$"
		classVariables: ''   "$NON-NLS$"
		poolDictionaries: '')  "$NON-NLS$"
			addSubAppMethods;
			yourself
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> addSubAppMethods [
	self 
		addMethod: (TonelReaderMethodDefinition loadedMethodFor: self name);
		addMethod: (TonelReaderMethodDefinition removingMethodFor: self name);
		addMethod: (TonelReaderMethodDefinition failedRemoveMethodFor: self name)
]

{ #category : 'loading-pools',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> amendSharedPoolClass [

	isSharedPool :=
		superclassIdentifier = #SharedPool
			ifTrue: [
				"self loader log: ('Ammending SharedPool <1p>' expandMacrosWith: name asSymbol)."
				self createPragmaMethod. 
				identifier := name asSymbol.	
				"superclassIdentifier := #Object." 
				"$NON-NLS$"
				"poolDictionaries := poolDictionaries copyWith: name."
				
				true ]
			ifFalse: [ false ]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> classCommentChangesIn: aClass [
	"Class extensions cannot supply a new class comment."
	
	^ self extension not
		and: [ self classComment ~= aClass comment ]
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> concreteClassIn: anApp [

	^anApp defined detect: [:ea | ea name = self identifier] ifNone: []
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> createDefinedIn: anApp using: aTonelLoader [

	(Smalltalk classAt: self identifier) notNil
		ifTrue: [self moveDefinedInto: anApp]
		ifFalse: [
			anApp owningImage
				defaultApplication: anApp
				during: [| residentSuperclass |
					residentSuperclass := self residentSuperclass.
					(residentSuperclass isClass
						ifTrue: [residentSuperclass]
						ifFalse: [residentSuperclass class])
							createClassNamed: self identifier
							subclassOf: self residentSuperclass
							variable: self variableClass
							fieldType: self fieldType
							classInstanceVariableString: ''
							instanceVariableString: ''
							classVariableString: ''
							sharedPoolString: '']]
]

{ #category : 'loading' }
TonelReaderClassDefinition >> createEditionIn: anApp using: aTonelLoader [
	"Creates an edition for receiver in anApp (or Subapp) using aTonelLoader."

	| baseClass |

	(baseClass := self concreteClassIn: anApp) isNil
		ifTrue: [self createIn: anApp using: aTonelLoader]
		ifFalse: [
			(self shouldCreateEditionOf: baseClass in: anApp using: aTonelLoader)
				ifTrue: [anApp newClassEditionFor: baseClass ifUnable: []]]
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> createExtendedIn: anApp using: aTonelLoader [

	EmInterface current extend: (Smalltalk classAt: self identifier) in: anApp
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> createIn: anApp using: aTonelLoader [

	self createDefinedIn: anApp using: aTonelLoader
]

{ #category : 'loading-pools',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> createPragmaMethod [

	self addMethod: (
		(TonelReaderMethodDefinition
			className: self name
			classSide: true
			categories: #('Tonel-Pool Definition') "$NON-NLS$"
			stamp: '') "$NON-NLS$"
				declaration: true;
				source: self pragmaSourceFromClassVariables).

	classVariables := '' "$NON-NLS$"
]

{ #category : 'loading-pools',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> createSharedPoolInitializerMethodFor: aTonelMethod [

	^('_SHAREDPOOL_' , self identifier , '_' , aTonelMethod selector) asSymbol
]

{ #category : 'loading-pools' }
TonelReaderClassDefinition >> declarePoolDictionariesIn: anApp using: aTonelLoader [
	"Loads the pool declaration methods in anApp
	 and rebuilds the namespaces after doing so."

	| previousCancelDeclaration |

	previousCancelDeclaration := EmImageBuilder cancelIfDeclarationErrors.
	[
		EmImageBuilder cancelIfDeclarationErrors: false.
		(tonelMethods select: [:each | each isDeclaration]) do: [:aTonelMethod |
			aTonelMethod loadFor: anApp into: anApp using: aTonelLoader.
			EmInterface current rebuildNamespaceFor: anApp]]
				ensure: [EmImageBuilder cancelIfDeclarationErrors: previousCancelDeclaration]
]

{ #category : 'loading-pools' }
TonelReaderClassDefinition >> definePoolDictionariesIn: anApp using: aTonelLoader [
	"Defines the methods used to initialize the values of shared pools
	 in anApp and invokes them afterwards."
	
	self isSharedPool 
		ifTrue: 
			[self poolInitializationMethods do: 
					[:aTonelMethod | 
					| selector methodCopy |
					selector := self createSharedPoolInitializerMethodFor: aTonelMethod.
					methodCopy := aTonelMethod copy.
					methodCopy selector: selector.
					methodCopy ammendSourceSelector.
					methodCopy 
						loadFor: anApp
						into: anApp
						using: aTonelLoader.
					anApp perform: selector]]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> hasChangesIn: emAppOrSubApp comparedTo: aClass [
	^ (self superclassChangeIn: aClass)
		or: [ (self methodChangesIn: aClass) notEmpty
			or: [ (self classCommentChangesIn: aClass)
				or: [ (self variableChangesIn: aClass)
					or: [ self hasMethodsRemovedFrom: aClass in: emAppOrSubApp ] ] ] ]
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> moveDefinedInto: anApp [
	| aClass |
	aClass := Smalltalk classAt: self identifier.
	aClass controller isEdition ifFalse: [aClass controller newEdition].
	aClass moveEditionFrom: aClass controller to: anApp
	
]

{ #category : 'loading-pools' }
TonelReaderClassDefinition >> poolInitializationMethods [
	"It is assumed that SharedPool initialization methods are unary and in the class side.
	 Usually a class side #initialize, but could also be something like #initializeConstants."

	^tonelMethods reject: [:each | each isDeclaration or: [each isClassSide not and: [each selector isUnary not]]]
]

{ #category : 'loading-pools',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> pragmaSourceFromClassVariables [

	^String streamContents: [:sourceStream |
		sourceStream
			nextPutAll: ('_PRAGMA_%1' bindWith: self name);
			cr;
			cr; "$NON-NLS$"
			nextPutAll: '"%%PRAGMA DECLARE';
			cr; "$NON-NLS$"
			tab;
			nextPutAll: ('(name:%1 isPool: true )' bindWith: self name);
			cr;
			cr. "$NON-NLS$"

		(self classVariables) do: [:eachVar | "$NON-NLS$"
			sourceStream
				nextPutAll: (
					' (name: %1 pool: %2 isConstant: false valueExpression: '''')'
						bindWith: eachVar
						with: self name); "$NON-NLS$"
				cr].

		sourceStream
			cr;
			cr;
			nextPutAll: '"'] "$NON-NLS$"


]

{ #category : 'accessing' }
TonelReaderClassDefinition >> residentSuperclass [
	"Answer the class represented by receiver that's actually in the image."

	(self superclassIdentifier isNil or: [self superclassIdentifier = 'nil']) ifTrue: [^nil].
	^Smalltalk
		classAt: self superclassIdentifier
		ifAbsent: [self halt: (TonelMsg10 bindWith: self name)]
]

{ #category : 'accessing',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> setIdentifier: aSymbol [
	"Sets the identifier of receiver to be aSymbol."
	
	identifier := aSymbol
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> superclassChangeIn: aClass [

	^self extension not and: [
		aClass superclass isNil
			ifTrue: [(self superclassIdentifier isNil and: [aClass superclass isNil]) not]
			ifFalse: [((self superclassIdentifier asSymbol = aClass superclass name asSymbol)) not]]
]

{ #category : 'comparing' }
TonelReaderClassDefinition >> tonelTopologicalSubordinateOf: aTonelLoaderClass [
	"This method will return true if the current TonelLoaderClass is a 
	  subclass or extension of aTonelLoaderClass."
	
	^(self superclassIdentifier = aTonelLoaderClass identifier)
		or: [self extension and: [
			aTonelLoaderClass extension not and: [
				self name = aTonelLoaderClass name]]]
]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> updateCommentIn: anApp [
	"If the receiver represents a class definition, then update the
	 class comment if it has changed."
	 	
	self extension ifFalse: [ | concreteClass |
		concreteClass := (self concreteClassIn: anApp).
		(concreteClass comment = self classComment)
			ifFalse: [ concreteClass comment: self classComment ] ]
]

{ #category : 'loading' }
TonelReaderClassDefinition >> updateVariables [
	"Updates the variables of the class defined by receiver,
	 to match the same variables as receiver."

	| aClass |

	aClass := Smalltalk classAt: self identifier.
	(aClass notNil and: [(self variableChangesIn: aClass) or: [self superclassChangeIn: aClass]])
		ifTrue: [
			aClass creatorClass
				createClassNamed: aClass environmentKey
				in: aClass environment
				for: (aClass hasController ifTrue: [aClass controller] ifFalse: [nil])
				subclassOf: self residentSuperclass
				instanceShape: aClass instanceShape
				classInstanceVariables: (self classInstanceVariables)
				instanceVariables: (self instanceVariables)
				classVariables: (self classVariables)
				sharedPoolNames: ((self poolDictionaries) collect: [:ea | ea asSymbol])]


]

{ #category : 'loading',
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> variableChangesIn: aClass [

	^ self extension not
		and: [
			((self instanceVariables) asSortedCollection ~= aClass instVarNames asSortedCollection)    "$NON-NLS$"
				 or: [ ((self classVariables) asSortedCollection ~= aClass classPool keys asSortedCollection)   "$NON-NLS$"
					or: [ ((self classInstanceVariables) asSortedCollection ~= aClass class instVarNames asSortedCollection)   "$NON-NLS$"
						or: [ ((self poolDictionaries) asSortedCollection ~= (aClass sharedPoolNames collect: [ :ea | ea asString ]) asSortedCollection) ] ] ] ]  "$NON-NLS$"
]
