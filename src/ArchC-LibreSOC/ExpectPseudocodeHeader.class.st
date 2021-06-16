Class {
	#name : #ExpectPseudocodeHeader,
	#superclass : #ParsingState,
	#category : #'ArchC-LibreSOC'
}

{ #category : #logic }
ExpectPseudocodeHeader >> transition: l [
	l = 'Pseudo-code:' ifFalse: [ self error ].
	^ExpectBlank op: op next: ExpectPseudoLine 
]
