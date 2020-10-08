Class {
	#name : #RegisterSemanticOperand,
	#superclass : #SemanticOperand,
	#instVars : [
		'type'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #logic }
RegisterSemanticOperand >> printConditionsOn: aStream instruction: instr [
	aStream 
		nextPutAll: '  is_';
		nextPutAll: type;
		nextPutAll: '(Op';
		nextPutAll: (number printString);
		nextPutAll: '),';
		cr
]

{ #category : #printing }
RegisterSemanticOperand >> printOn: aStream [
	aStream
		nextPutAll: 'Op';
		nextPutAll: (number printString);
		nextPut: $:;
		nextPutAll: type
	
]

{ #category : #accessing }
RegisterSemanticOperand >> type [
	^ type
]

{ #category : #accessing }
RegisterSemanticOperand >> type: anObject [
	type := anObject
]
