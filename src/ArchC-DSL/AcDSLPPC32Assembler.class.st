Class {
	#name : #AcDSLPPC32Assembler,
	#superclass : #AcDSLAssembler,
	#category : #'ArchC-DSL'
}

{ #category : #initialization }
AcDSLPPC32Assembler class >> initialize [
	"AcDSLAssemblerGenerator generate: self"
]

{ #category : #accessing }
AcDSLPPC32Assembler class >> isa [
	^ AcProcessorDescriptions powerpc
]

{ #category : #extended }
AcDSLPPC32Assembler >> mr: operands [
	self assert: operands size == 2.
	 ^ self append: 'or' operands: (operands copyWith: operands last).
]
