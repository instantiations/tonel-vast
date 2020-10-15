Extension {
	#name : 'TonelReaderClassDefinition'
}

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Initialize-Release'] }
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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Initialize-Release'] }
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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> addSubAppMethods [
	self 
		addMethod: (TonelReaderMethodDefinition loadedMethodFor: self name);
		addMethod: (TonelReaderMethodDefinition removingMethodFor: self name);
		addMethod: (TonelReaderMethodDefinition failedRemoveMethodFor: self name)
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-pools'],
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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> classCommentChangesIn: aClass [
	"Class extensions cannot supply a new class comment."
	
	^ self extension not
		and: [ self classComment ~= aClass comment ]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> concreteClassIn: anApp [

	^anApp defined detect: [:ea | ea name = self identifier] ifNone: []
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> createDefinedIn: anApp using: aTonelLoader [

	(Smalltalk classAt: self identifier) notNil
		ifTrue: [self moveDefinedInto: anApp]
		ifFalse: [
			anApp owningImage
				defaultApplication: anApp
				during: [
					(Smalltalk
						classAt: self superclassIdentifier
						ifAbsent: [self halt: (TonelMsg10 bindWith: self name)])
							createClassNamed: self identifier
							subclassOf: (Smalltalk classAt: self superclassIdentifier)
							variable: self variableClass
							fieldType: self fieldType
							classInstanceVariableString: ''
							instanceVariableString: ''
							classVariableString: ''
							sharedPoolString: '' "$NLS$ Missing superclass for %1" "$NON-NLS$" "$NON-NLS$" "$NON-NLS$"]] "$NON-NLS$"
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderClassDefinition >> createEditionIn: anApp using: aTonelLoader [

	| baseClass |
	(baseClass := self concreteClassIn: anApp) isNil 
		ifTrue: [self createIn: anApp using: aTonelLoader]
		ifFalse: 
			[(self 
				shouldCreateEditionOf: baseClass
				in: anApp
				using: aTonelLoader) 
					ifTrue: [anApp newClassEditionFor: baseClass ifUnable: []]]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> createExtendedIn: anApp using: aTonelLoader [

	EmInterface current extend: (Smalltalk classAt: self identifier) in: anApp
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> createIn: anApp using: aTonelLoader [

	self createDefinedIn: anApp using: aTonelLoader
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-pools'],
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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-pools'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> createSharedPoolInitializerMethodFor: aTonelMethod [

	^('_SHAREDPOOL_' , self identifier , '_' , aTonelMethod selector) asSymbol
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-pools'] }
TonelReaderClassDefinition >> declarePoolDictionariesIn: anApp using: aTonelLoader [

	(tonelMethods select: [:each | each isDeclaration]) do: 
			[:aTonelMethod | 
			aTonelMethod 
				loadFor: anApp
				into: anApp
				using: aTonelLoader.
			EmInterface current rebuildNamespaceFor: anApp]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-pools'] }
TonelReaderClassDefinition >> definePoolDictionariesIn: anApp using: aTonelLoader [

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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> hasChangesIn: emAppOrSubApp comparedTo: aClass [
	^ (self superclassChangeIn: aClass)
		or: [ (self methodChangesIn: aClass) notEmpty
			or: [ (self classCommentChangesIn: aClass)
				or: [ (self variableChangesIn: aClass)
					or: [ self hasMethodsRemovedFrom: aClass in: emAppOrSubApp ] ] ] ]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> moveDefinedInto: anApp [
	| aClass |
	aClass := Smalltalk classAt: self identifier.
	aClass controller isEdition ifFalse: [aClass controller newEdition].
	aClass moveEditionFrom: aClass controller to: anApp
	
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-pools'] }
TonelReaderClassDefinition >> poolInitializationMethods [
	"It is assumed that SharedPool initialization methods are unary and in the class side.
	 Usually a class side #initialize, but could also be something like #initializeConstants."

	^tonelMethods reject: [:each | each isDeclaration or: [each isClassSide not and: [each selector isUnary not]]]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading-pools'],
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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['accessing'] }
TonelReaderClassDefinition >> rootTonelApplicationIn: aTonelLoader [


	^aTonelLoader rootApplicationOfClass: self
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> superclassChangeIn: aClass [
	^self extension not
		and: [(self superclassIdentifier = aClass superclass name) not]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['accessing'] }
TonelReaderClassDefinition >> tonelSuperclassIn: aTonelLoader [

	
	^aTonelLoader tonelClassNamed: self superclassIdentifier
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['comparing'] }
TonelReaderClassDefinition >> tonelTopologicalSubordinateOf: aTonelLoaderClass [
	"This method will return true if the current TonelLoaderClass is a 
	  subclass or extension of aTonelLoaderClass."
	
	^(self superclassIdentifier = aTonelLoaderClass identifier)
		or: [self extension and: [
			aTonelLoaderClass extension not and: [
				self name = aTonelLoaderClass name]]]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> updateCommentIn: anApp [
	"If the receiver represents a class definition, then update the
	 class comment if it has changed."
	 	
	self extension ifFalse: [ | concreteClass |
		concreteClass := (self concreteClassIn: anApp).
		(concreteClass comment = self classComment)
			ifFalse: [ concreteClass comment: self classComment ] ]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'] }
TonelReaderClassDefinition >> updateVariables [

	| aClass |

	aClass := Smalltalk classAt: self identifier.
	(aClass notNil and: [(self variableChangesIn: aClass) or: [self superclassChangeIn: aClass]])
		ifTrue: [
			aClass creatorClass
				createClassNamed: aClass environmentKey
				in: aClass environment
				for: (aClass hasController ifTrue: [aClass controller] ifFalse: [nil])
				subclassOf: (Smalltalk classAt: self superclassIdentifier)
				instanceShape: aClass instanceShape
				classInstanceVariables: (self classInstanceVariables)
				instanceVariables: (self instanceVariables)
				classVariables: (self classVariables)
				sharedPoolNames: ((self poolDictionaries) collect: [:ea | ea asSymbol])]


]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['loading'],
  #vaVisibility : 'private' }
TonelReaderClassDefinition >> variableChangesIn: aClass [

	^ self extension not
		and: [
			((self instanceVariables) asSortedCollection ~= aClass instVarNames asSortedCollection)    "$NON-NLS$"
				 or: [ ((self classVariables) asSortedCollection ~= aClass classPool keys asSortedCollection)   "$NON-NLS$"
					or: [ ((self classInstanceVariables) asSortedCollection ~= aClass class instVarNames asSortedCollection)   "$NON-NLS$"
						or: [ ((self poolDictionaries) asSortedCollection ~= (aClass sharedPoolNames collect: [ :ea | ea asString ]) asSortedCollection) ] ] ] ]  "$NON-NLS$"
]
