Class {
	#name : #ExpectDesc,
	#superclass : #ParsingState,
	#category : #'ArchC-LibreSOC'
}

{ #category : #'as yet unclassified' }
ExpectDesc class >> initial [
	^self new: MdwnInstruction new
]

{ #category : #logic }
ExpectDesc >> transition: l [
	l isEmpty ifTrue: [ ^self ].
	(l beginsWith: '<!--') ifTrue: [ ^self ].
	(l beginsWith: '#') ifFalse: [ self error ].
	op desc: l copyWithoutFirst stripLeftSeparator.
	^ExpectBlank op: op next: ExpectForm 
]
