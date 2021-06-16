Class {
	#name : #ExpectSpecialRegister,
	#superclass : #ParsingState,
	#category : #'ArchC-LibreSOC'
}

{ #category : #logic }
ExpectSpecialRegister >> transition: l [
	l isEmpty ifTrue: [ ^ParsingDone new: op ].
	(l beginsWith: '    ') ifFalse: [ self error ].
	op sregs add: (l copyFrom: 5 to: l size).
	^self
]
