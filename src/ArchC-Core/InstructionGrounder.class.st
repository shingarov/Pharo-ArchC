"
I turn instances of ProcessorInstructionDefinition into equivalent instances of ProcessorInstruction.

ProcessorInstructionDefinition and ProcessorInstruction -- just as well as everything else in this package -- treat the ISA in a target-agnostic, PDL-driven manner.  However, some higher-layer tools may have knowledge about a particular ISA that they wish to express in explicit code.  For this, creating an ISA-specific subclass of ProcessorInstruction may be appropriate.  In that case, I will provide a link between the PDL object and that target-aware subclass.
"
Class {
	#name : #InstructionGrounder,
	#superclass : #Object,
	#instVars : [
		'processorInstructionClass'
	],
	#category : #'ArchC-Core-Core'
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
