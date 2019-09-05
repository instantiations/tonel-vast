Extension {
	#name : 'SequenceableCollection'
}

{
	#category : '*TonelReaderModel',
	#vaCategories : ['Not categorized']
}
SequenceableCollection >> pairsCollect: aBlock [
	"Evaluate aBlock with my elements taken two at a time, and return an Array with the results"

	"(#(1 'fred' 2 'charlie' 3 'elmer') pairsCollect: [:a :b | b, ' is number ', a printString]) >>> #('fred is number 1' 'charlie is number 2' 'elmer is number 3')"

	^ (1 to: self size // 2)
		collect: [ :index | aBlock value: (self at: 2 * index - 1) value: (self at: 2 * index) ]
]
