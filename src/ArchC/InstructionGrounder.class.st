"
I turn instances of ProcessorInstructionDefinition into equivalent instances of ProcessorInstruction.
"
Class {
	#name : #InstructionGrounder,
	#superclass : #Object,
	#instVars : [
		'processorInstructionClass'
	],
	#category : #'ArchC-Core'
}

{ #category : #API }
InstructionGrounder >> ground: anInstructionDeclaration [
	^anInstructionDeclaration as: self processorInstructionClass 
]

{ #category : #accessing }
InstructionGrounder >> processorInstructionClass [
	processorInstructionClass isNil ifTrue: [ processorInstructionClass := ProcessorInstruction ].
	^ processorInstructionClass
]

{ #category : #accessing }
InstructionGrounder >> processorInstructionClass: aClass [
	processorInstructionClass := aClass
]
