Extension {
	#name : 'SubApplication'
}

{ #category : '*TonelWriterModel',
 #vaCategories : ['Not categorized'],
  #vaVisibility : 'private' }
SubApplication class >> computeTonelPackageTag [
	"Private - Computes the receiver package Tag.
	 Note: This is the last resort option when there is no explicit packageTag defined,
	 if the receiver name has part of the root app name in it (with or without a common 'App' suffix)
	 then it tries to separate the receiver name from the rootApplication name, otherwise it returns the receiver name."

	| rootAppName |
	rootAppName := rootApplication name.
	(rootAppName endsWithSubCollection: 'App') 
		ifTrue: [rootAppName := rootAppName copyFrom: 1 to: rootAppName size - 3].
	^((self name beginsWithSubCollection: rootAppName)  and: [rootAppName size < self name size])
		ifTrue: [self name copyFrom: rootAppName size + 1 to: self name size]
		ifFalse: [self name]
]

{ #category : '*TonelWriterModel',
 #vaCategories : ['Tonel-Metadata'],
  #vaVisibility : 'private' }
SubApplication class >> tonelPackageName [

	^(self class selectors includes: #_TONEL_packageName)
		ifTrue: [self perform: #_TONEL_packageName]
		ifFalse: [self name asString]
]

{ #category : '*TonelWriterModel',
 #vaCategories : ['Not categorized'],
  #vaVisibility : 'private' }
SubApplication class >> tonelPackageTag [

	^(self class selectors includes: #_TONEL_packageTag)
		ifTrue: [self perform: #_TONEL_packageTag]
		ifFalse: [self computeTonelPackageTag]
]
