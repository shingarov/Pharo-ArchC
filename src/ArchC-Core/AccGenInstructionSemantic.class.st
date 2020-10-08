Class {
	#name : #AccGenInstructionSemantic,
	#superclass : #Object,
	#instVars : [
		'trees',
		'cost',
		'hasDelaySlot',
		'instruction'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AccGenInstructionSemantic class >> trees: aSequenceOfSemanticTrees cost: anInteger hasDelaySlot: aBoolean [
	^self new
		trees: aSequenceOfSemanticTrees ;
		cost: anInteger ;
		hasDelaySlot: aBoolean ;
		yourself
]

{ #category : #accessing }
AccGenInstructionSemantic >> cost [
	^ cost
]

{ #category : #accessing }
AccGenInstructionSemantic >> cost: anObject [
	cost := anObject
]

{ #category : #accessing }
AccGenInstructionSemantic >> hasDelaySlot [
	^ hasDelaySlot
]

{ #category : #accessing }
AccGenInstructionSemantic >> hasDelaySlot: anObject [
	hasDelaySlot := anObject
]

{ #category : #accessing }
AccGenInstructionSemantic >> instruction [
	^ instruction
]

{ #category : #accessing }
AccGenInstructionSemantic >> instruction: backPtrToInstruction [
	instruction := backPtrToInstruction.
	trees do: [ :aSemanticTree | aSemanticTree instruction: backPtrToInstruction ]
]

{ #category : #logic }
AccGenInstructionSemantic >> printLogicOn: aStream [
	trees do: [ :semTree | semTree printLogicOn: aStream. aStream lf ]
]

{ #category : #accessing }
AccGenInstructionSemantic >> trees [
	^ trees
]

{ #category : #accessing }
AccGenInstructionSemantic >> trees: anObject [
	trees := anObject
]
