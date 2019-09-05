Extension {
	#name : 'EmClassDefinition'
}

{
	#category : '*TonelWriterModel',
	#vaCategories : ['EM-Internal']
}
EmClassDefinition >> tonelKindOfSubclass [
	"Private - Answer a string describing the receiver type.
	 This is similar to #kindOfSubclass but trying to use Tonel/Pharo 
	 keywords for the type"

	self isFixed ifTrue: [^'pointers']. 
	self isBytes ifTrue: [^'bytes'].  
	self isWords ifTrue: [^'words'].  
	self isLongs ifTrue: [^'longs'].  
	^'variable'  
]
