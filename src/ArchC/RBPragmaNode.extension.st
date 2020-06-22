Extension { #name : #RBPragmaNode }

{ #category : #'*ArchC' }
RBPragmaNode >> assemblyISA [
	| unarySel |
	unarySel := self selector allButLast asSymbol.
	(AcProcessorDescriptions respondsTo: unarySel) ifFalse: [ ^nil ].
	^self selector -> (AcProcessorDescriptions perform: unarySel)
]

{ #category : #'*ArchC' }
RBPragmaNode >> firstLiteralArgument [
	^self arguments first value
]
