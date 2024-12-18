Extension {
	#name : 'EsString'
}

{ #category : 'Converting' }
EsString >> normalizedLineDelimiter [
  ^(String streamContents: [:outputStream | 
	| sourceStream |
	sourceStream := self readStream.
	[ sourceStream atEnd ] whileFalse: [ outputStream nextPutAll: sourceStream nextLine.
		sourceStream atEnd ifFalse: [ outputStream newLine ]]
   ]) trimBlanks
]
