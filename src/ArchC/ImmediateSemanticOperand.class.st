Class {
	#name : #ImmediateSemanticOperand,
	#superclass : #SemanticOperand,
	#category : #'ArchC-Core'
}

{ #category : #logic }
ImmediateSemanticOperand >> printConditionsOn: aStream instruction: instruction [
	aStream 
		nextPutAll: '  integer(Op';
		nextPutAll: (number printString);
		nextPutAll: '), Op';
		nextPutAll: (number printString);
		nextPutAll: ' < ';
		nextPutAll: ((1 << instruction isa tgtimm) printString);
		nextPut: $,;
		cr
]
