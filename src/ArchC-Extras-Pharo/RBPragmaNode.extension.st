Extension { #name : #RBPragmaNode }

{ #category : #'*ArchC-Extras-Pharo' }
RBPragmaNode >> assemblyISA [
	| unarySel |
	unarySel := self selector allButLast asSymbol.
	(AcProcessorDescriptions respondsTo: unarySel) ifFalse: [ ^nil ].
	^self selector -> (AcProcessorDescriptions perform: unarySel)
]

{ #category : #'*ArchC-Extras-Pharo' }
RBPragmaNode >> firstLiteralArgument [
	^self arguments first value
]
