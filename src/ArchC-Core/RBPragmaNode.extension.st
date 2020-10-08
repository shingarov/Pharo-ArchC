Extension { #name : #RBPragmaNode }

{ #category : #'*ArchC-Core' }
RBPragmaNode >> assemblyISA [
	| unarySel |
	unarySel := self selector allButLast asSymbol.
	(AcProcessorDescriptions respondsTo: unarySel) ifFalse: [ ^nil ].
	^self selector -> (AcProcessorDescriptions perform: unarySel)
]

{ #category : #'*ArchC-Core' }
RBPragmaNode >> firstLiteralArgument [
	^self arguments first value
]
