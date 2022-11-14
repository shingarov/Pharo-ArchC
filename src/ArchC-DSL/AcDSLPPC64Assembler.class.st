Class {
	#name : #AcDSLPPC64Assembler,
	#superclass : #AcDSLAssembler,
	#category : #'ArchC-DSL'
}

{ #category : #accessing }
AcDSLPPC64Assembler class >> isa [
	^ AcProcessorDescriptions powerpc64
]
