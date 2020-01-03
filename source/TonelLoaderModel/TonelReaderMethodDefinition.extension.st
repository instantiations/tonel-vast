Extension {
	#name : 'TonelReaderMethodDefinition'
}

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Static Methods'] }
TonelReaderMethodDefinition class >> failedRemoveMethodFor: nameString [

	^ (self 
		className: nameString
		classSide: true
		categories: 'loading/removing'  "$NON-NLS$"
		stamp: '')  "$NON-NLS$"
			source: self failedRemoveSource;
			yourself
			
		
		
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Static Methods'],
  #vaVisibility : 'private' }
TonelReaderMethodDefinition class >> failedRemoveSource [

	^ 'failedRemove

	self loaded'  "$NON-NLS$"
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Static Methods'] }
TonelReaderMethodDefinition class >> loadedMethodFor: nameString [

	^ (self 
		className: nameString
		classSide: true
		categories: 'loading/removing'  "$NON-NLS$"
		stamp: '')  "$NON-NLS$"
			source: self loadedSource;
			yourself
			
		
		
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Static Methods'],
  #vaVisibility : 'private' }
TonelReaderMethodDefinition class >> loadedSource [

	^ 'loaded
	"Send #initializeOnLoad to every class defined in this subapplication that implements it."

	defined do: [ :aClass |
		(aClass class includesSelector: #initializeOnLoad) ifTrue: [ aClass initializeOnLoad ] ]'	"$NON-NLS$"
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Static Methods'] }
TonelReaderMethodDefinition class >> newInitializeMethodFor: nameString [

	^ (self 
		className: nameString
		classSide: true
		categories: #('instance creation')   "$NON-NLS$"
		stamp: '')  "$NON-NLS$"
			source: self newInitializeSource;
			yourself
			
		
		
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Static Methods'],
  #vaVisibility : 'private' }
TonelReaderMethodDefinition class >> newInitializeSource [

	^ 'new

	^super new initialize'	"$NON-NLS$"
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Static Methods'] }
TonelReaderMethodDefinition class >> removingMethodFor: nameString [

	^ (self 
		className: nameString
		classSide: true
		categories: 'loading/removing'  "$NON-NLS$"
		stamp: '')  "$NON-NLS$"
			source: self removingSource;
			yourself
			
		
		
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Static Methods'],
  #vaVisibility : 'private' }
TonelReaderMethodDefinition class >> removingSource [

	^ 'removing
	"Send #unload to every class defined in this subapplication that implements it."

	defined do: [ :aClass |
		(aClass class includesSelector: #unload) ifTrue: [ aClass unload ] ]'	"$NON-NLS$"
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Loading-Internal'],
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> commentedSource [
	
	^ String streamContents: [ :outStream | | inStream |
		inStream := ReadStream on: self source.
		outStream
			nextPutAll: inStream nextLine; cr; 
			nextPutAll: TonelMsg16; cr.  "$NLS$ '""The following source failed to compile (all double quotes have been doubled):"
		[ inStream atEnd ]  whileFalse: [
			inStream nextLine do: [ :eachChar |
				eachChar = $"
					ifTrue: [ outStream nextPut: $" ].
				outStream nextPut: eachChar ].
			outStream cr ].
		outStream
			nextPut: $"; cr; cr; "If the method is executed, halt execution to make the problem very obvious"
			tab; nextPutAll: TonelMsg17 ]  "$NLS$ ^ self halt: 'The source for this method failed to compile'"
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Loading-Internal'],
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> hasChangesIn: aClass [
	^(self isUnchangedIn: aClass) not
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Loading-Internal'],
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> hasSourceChangesIn: aClass [
	| aMethod |

	aMethod := (self onSideClass: aClass) methodDictionary
			detect: [ :ea | ea selector = self selector ]
			ifNone: [ ].
	^ aMethod isNil "there is no method"
		or: ["the source is different (doesn't match the source or the commented source)"
			((aMethod sourceString = self source) 
				or: [
					aMethod sourceString = self commentedSource]) not]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['testing'],
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> isUnchangedIn: aClass [

	| aMethod |
		
	aMethod := (self onSideClass: aClass) methodDictionary
			detect: [ :ea | ea selector = self selector ]
			ifNone: [ ].
	^ aMethod notNil "a method was found"
		and: [ "the method is in the same categories"
			(self categories asOrderedCollection = ((self onSideClass: aClass) categoriesFor: self selector) asOrderedCollection)
				and: ["the source is the same"
					(aMethod sourceString = self source) 
						or: [ "the source matches the non-compiled source warning from a Monticello load"
							aMethod sourceString = self commentedSource ] ] ]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Loading-Internal'],
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

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Loading'] }
TonelReaderMethodDefinition >> loadFor: aClass into: anApp using: aTonelLoader [

	(aTonelLoader alwaysCreateEditions or: [(self hasChangesIn: aClass)])
		ifTrue: 
			["Recompile if the source has changed"

			(aTonelLoader alwaysCreateEditions or: [(self hasSourceChangesIn: aClass)]) 
				ifTrue: 
					[((self onSideClass: aClass) 
						basicCompile: self source
						notifying: Transcript
						ifFail: [self loadFailedFor: (self onSideClass: aClass) into: anApp]) 
							ifNotNil: 
								[:compiledMethod | 
								(self onSideClass: aClass) 
									install: compiledMethod
									asPrivate: self isPrivate
									withSource: self source
									ifNewAddTo: anApp
									categorizeIn: self categories]	"Have it notify itself?"].
			"Recategorize (whether or not source has changed)"
			(self onSideClass: aClass) 
				categorizeSelectors: (Array with: self selector)
				in: self categories]
]

{ #category : '*TonelLoaderModel',
 #vaCategories : ['Loading-Internal'],
  #vaVisibility : 'private' }
TonelReaderMethodDefinition >> onSideClass: aClass [
	^self isClassSide
		ifTrue: [aClass class]
		ifFalse: [aClass]
]
