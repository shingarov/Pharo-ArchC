Class {
	#name : #SemanticOperand,
	#superclass : #Object,
	#instVars : [
		'number'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #logic }
SemanticOperand >> addOperandNumbersTo: aSet [ 
	aSet add: number.
	^aSet
]

{ #category : #accessing }
SemanticOperand >> number [
	^ number
]

{ #category : #accessing }
SemanticOperand >> number: anObject [
	number := anObject
]

{ #category : #logic }
SemanticOperand >> printConditionsOn: aStream instruction: instr [
	self subclassResponsibility 
]

{ #category : #logic }
SemanticOperand >> printRewriteHeadOn: aStream [
	aStream nextPutAll: 'Op', number printString 
]
