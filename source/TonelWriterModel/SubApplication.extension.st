Extension {
	#name : 'SubApplication'
}

{ #category : '*TonelWriterModel',
 #vaCategories : ['Tonel-Metadata'],
  #vaVisibility : 'private' }
SubApplication class >> tonelPackageName [

	^(self class selectors includes: #_TONEL_packageName)
		ifTrue: [self perform: #_TONEL_packageName]
		ifFalse: [self name asString]
]
