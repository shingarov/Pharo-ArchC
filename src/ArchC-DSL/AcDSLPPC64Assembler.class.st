Class {
	#name : #AcDSLPPC64Assembler,
	#superclass : #AcDSLAssembler,
	#category : #'ArchC-DSL'
}

{ #category : #accessing }
AcDSLPPC64Assembler class >> isa [
	^ AcProcessorDescriptions powerpc64
]

{ #category : #extended }
AcDSLPPC64Assembler >> mr: operands [
	self assert: operands size == 2.
	 ^ self append: 'or' operands: (operands copyWith: operands last).
]
