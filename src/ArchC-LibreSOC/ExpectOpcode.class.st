Class {
	#name : #ExpectOpcode,
	#superclass : #ParsingState,
	#category : #'ArchC-LibreSOC'
}

{ #category : #logic }
ExpectOpcode >> transition: l [
	l isEmpty ifTrue: [ ^ExpectPseudocodeHeader new: op ].
	(l beginsWith: '*') ifFalse: [ self error ].
	op opcodes add: l copyWithoutFirst stripLeftSeparator.
	^self
]
