Extension {
	#name : 'Collection'
}

{
	#category : '*TonelReaderModel',
	#vaCategories : ['ES-Portability']
}
Collection >> flattened [
	"Flattens a collection of collections (no matter how many levels of collections exist). Strings are considered atoms and, as such, won't be flattened"
	"( #(1 #(2 3) #(4 #(5))) flattened ) >>> #(1 2 3 4 5)" 
	"( #('string1' #('string2' 'string3')) flattened ) >>> #('string1' 'string2' 'string3')"
	
	^ Array streamContents: [ :stream | self flattenOn: stream].
]

{
	#category : '*TonelReaderModel',
	#vaCategories : ['ES-Portability']
}
Collection >> flattenOn: aStream [

	self do: [:each |
		(each isCollection and: [each isString not])
			ifTrue: [each flattenOn: aStream]
			ifFalse: [aStream nextPut: each]]
]
