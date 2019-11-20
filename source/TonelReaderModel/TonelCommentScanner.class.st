"
I scan comments.
"
Class {
	#name : 'TonelCommentScanner',
	#superclass : 'TonelScanner',
	#category : 'TonelReaderModel'
}

{ #category : 'scanning' }
TonelCommentScanner >> scan [

	| result ch eatNext |

	result := String new writeStream.
	eatNext := false.
	stream next = $" ifFalse: [TonelParseError signal: 'Can''t parse comment'].
	[stream atEnd not and: [(ch := stream next) ~= $" or: [eatNext := stream peek = $"]]] whileTrue: [
		result nextPut: ch.
		eatNext
			ifTrue: [
				stream skip: 1.
				eatNext := false]].
	"This is a hack to make my clean algoritm for bodies work also for 
	comments. I need to refactor the 'eat enter' part out to use just that."
	^self removeFrom: (('"' , result contents , '"')) enclosingStart: $" end: $"
]
