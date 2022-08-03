Extension {
	#name : 'TonelReaderMethodDefinition'
}

{ #category : 'Static Methods' }
TonelReaderMethodDefinition class >> failedRemoveMethodFor: nameString [
	"Answer a new instance of receiver containing the source code
	 for the #failedRemove ENVY method hook."
	
	^ (self 
		className: nameString
		classSide: true
		categories: #('loading/removing')  "$NON-NLS$"
		stamp: '')  "$NON-NLS$"
			source: self failedRemoveSource;
			yourself
			
		
		
]

{ #category : 'Static Methods',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition class >> failedRemoveSource [

	^ 'failedRemove

	self loaded'  "$NON-NLS$"
]

{ #category : 'Static Methods' }
TonelReaderMethodDefinition class >> loadedMethodFor: nameString [
	"Answer a new instance of receiver containing the source code
	 required to initialize receiver in the #loaded ENVY hook."

	^ (self 
		className: nameString
		classSide: true
		categories: #('loading/removing')  "$NON-NLS$"
		stamp: '')  "$NON-NLS$"
			source: self loadedSource;
			yourself
			
		
		
]

{ #category : 'Static Methods',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition class >> loadedSource [

	^ 'loaded
	"Send #initialize to every class defined in this subapplication that implements it."

	defined do: [ :aClass |
		(aClass class includesSelector: #initialize) ifTrue: [ aClass perform: #initialize ] ]'	"$NON-NLS$"
]

{ #category : 'Static Methods' }
TonelReaderMethodDefinition class >> newInitializeMethodFor: nameString [
	"Answer a new instance of receiver containing the source code
	 for an #initialize method."

	^ (self 
		className: nameString
		classSide: true
		categories: #('instance creation')   "$NON-NLS$"
		stamp: '')  "$NON-NLS$"
			source: self newInitializeSource;
			yourself
			
		
		
]

{ #category : 'Static Methods',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition class >> newInitializeSource [

	^ 'new

	^super new initialize'	"$NON-NLS$"
]

{ #category : 'Static Methods' }
TonelReaderMethodDefinition class >> removingMethodFor: nameString [
	"Answer a new instance of receiver containing the source code
	 for the #removing ENVY method hook."

	^ (self 
		className: nameString
		classSide: true
		categories: #('loading/removing')  "$NON-NLS$"
		stamp: '')  "$NON-NLS$"
			source: self removingSource;
			yourself
			
		
		
]

{ #category : 'Static Methods',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition class >> removingSource [

	^ 'removing
	"Send #unload to every class defined in this subapplication that implements it."

	defined do: [ :aClass |
		(aClass class includesSelector: #unload) ifTrue: [ aClass perform: #unload ] ]'	"$NON-NLS$"
]

{ #category : 'Loading-Internal',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> commentedSource [

	^String streamContents: [:outStream | | inStream |
		inStream := ReadStream on: self source.
		outStream
			nextPutAll: inStream nextLine;
			cr;
			nextPut: Character tab;
			nextPut: $";
			nextPutAll: TonelMsg16; "$NLS$ 'The following source failed to compile (all double quotes have been doubled):"
			nextPut: $";
			cr.
			
		outStream nextPut: $".
		[inStream atEnd] whileFalse: [
			outStream cr.
			inStream nextLine do: [:eachChar |
				eachChar = $" ifTrue: [outStream nextPut: $"].
				outStream nextPut: eachChar].
			].
		outStream
			nextPut: $";
			cr;
			nextPutAll: '#tonelCompilationFailure.';
			cr;
			cr;
			nextPutAll: TonelMsg17] "$NLS$ ^ self halt: 'The source for this method failed to compile'"
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> hasCategoryChangesIn: aClass [
	"Answer whether there are category changes between receiver
	 and the method with the same selector defined in aClass."

	^self categories asSortedCollection 
		~= ((self onSideClass: aClass) categoriesFor: self selector) 
				asSortedCollection
]

{ #category : 'testing' }
TonelReaderMethodDefinition >> hasChangesIn: aClass [
	"Answer whether receiver has changes in aClass."

	^((self onSideClass: aClass) methodDictionary
		detect: [:ea | ea selector = self selector]
		ifNone: []) notNil
		or: [(self hasCategoryChangesIn: aClass) or: [self hasSourceChangesIn: aClass]]
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> hasMethodDefinedIn: aClass [
	"Answer whether receiver has a method with the same selector defined in aClass."

	^((self onSideClass: aClass) methodDictionary
		detect: [:ea | ea selector = self selector]
		ifNone: [])
			notNil
]

{ #category : 'testing',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> hasSourceChangesIn: aClass [
	"Answer whether receiver has different source than the same method defined in aClass.
	 If there is no method defined, then we assume the source has changes."

	| aMethod |

	aMethod :=
		(self onSideClass: aClass) methodDictionary
			detect: [:ea | ea selector = self selector]
			ifNone: [].
	^aMethod isNil or: [((aMethod sourceString ~= self source))]
]

{ #category : 'Loading-Internal',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> loadFailedFor: aClass into: anApp [

	(aClass
		basicCompile: self commentedSource
		notifying: Transcript
		ifFail: ["Well now we're really in trouble"])
			ifNotNil: [:compiledMethod |
				aClass
					install: compiledMethod
					asPrivate: self isPrivate
					withSource: self commentedSource
					ifNewAddTo: anApp
					categorizeIn: self categories , #('Tonel-Compile Failed') ].	"$NON-NLS$"
	^nil
]

{ #category : 'Loading' }
TonelReaderMethodDefinition >> loadFor: aClass into: anApp using: aTonelLoader [

	(self hasChangesIn: aClass)
		ifTrue: [ "Recompile if the source has changed"
			(self hasSourceChangesIn: aClass)
				ifTrue: [
					((self onSideClass: aClass)
						basicCompile: self source
						notifying: Transcript
						ifFail: [self loadFailedFor: (self onSideClass: aClass) into: anApp])
							ifNotNil: [:compiledMethod |
								(self onSideClass: aClass)
									install: compiledMethod
									asPrivate: self isPrivate
									withSource: self source
									ifNewAddTo: anApp
									categorizeIn: self categories] "Have it notify itself?"].
			"Recategorize (whether or not source has changed)"
			(self onSideClass: aClass)
				categorizeSelectors: (Array with: self selector)
				in: self categories]
]

{ #category : 'Loading-Internal',
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> onSideClass: aClass [
	^self isClassSide
		ifTrue: [aClass class]
		ifFalse: [aClass]
]

{ #category : 'Loading' }
TonelReaderMethodDefinition >> referencedTonelClasses: aTonelLoader [
	"Answer a collection of the TonelReaderClassDefinitions 
	 referenced by receiver source code."

	| result classNames |

	result :=
		EsCompiler
			parse: self source
			environment: (EsCompiler nameEnvironmentForClass: UndefinedObject)
			messagePattern: true
			scanComments: false
			errorHandler: EsSilentErrorHandler new.
	classNames := Set new.
	result parseTree ifNotNil: [:parseTree |
		parseTree allNodesDo: [:node |
			((node isKindOf: EsVariableWithBinding) and: [node contents first isUppercase])
				ifTrue: [classNames add: node contents asSymbol]]].
	^classNames collect: [:each | aTonelLoader tonelClassNamed: each]


]
