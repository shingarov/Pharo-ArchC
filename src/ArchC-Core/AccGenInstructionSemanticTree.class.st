Class {
	#name : #AccGenInstructionSemanticTree,
	#superclass : #Object,
	#instVars : [
		'source',
		'instruction',
		'term',
		'let'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AccGenInstructionSemanticTree class >> let: let in: source [
	^self new 
		let: let;
		source: source;
		yourself
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> instruction [
	^ instruction
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> instruction: backPtrToInstruction [
	instruction := backPtrToInstruction
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> let [
	^ let
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> let: anObject [
	let := anObject
]

{ #category : #logic }
AccGenInstructionSemanticTree >> printLetOn: aStream [
	let keysAndValuesDo: [ :k :v |
		aStream
			nextPutAll: '  Op';
			nextPutAll: (k printString);
			nextPutAll: ' = '.
		v putOn: aStream.
		aStream
			nextPut: $,;
			cr ]
]

{ #category : #logic }
AccGenInstructionSemanticTree >> printLogicOn: aStream [
	term printRewriteHeadOn: aStream.
	aStream nextPutAll: ' => ';
		nextPutAll: instruction name;
		nextPut: $(.
	self printOperandNumbersOn: aStream.
	aStream
		nextPut: $);
		nextPutAll: ' :-';
		lf.
	self printLetOn: aStream.
	term printConditionsOn: aStream instruction: instruction.
	aStream nextPutAll: '  true.'
]

{ #category : #logic }
AccGenInstructionSemanticTree >> printOperandNumbersOn: aStream [
	| operandNumbers  |
	operandNumbers := (term addOperandNumbersTo: let keys asSet) sorted collect: [ :n | 'Op', n printString ].
	operandNumbers printUsing: #putOn: on: aStream
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> source [
	^ source
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> source: anObject [
	source := anObject.
	term := AcSemanticTermParser new parse: source.
]
