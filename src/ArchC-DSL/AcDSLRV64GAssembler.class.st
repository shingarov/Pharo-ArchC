Class {
	#name : #AcDSLRV64GAssembler,
	#superclass : #AcDSLAssembler,
	#category : #'ArchC-DSL'
}

{ #category : #initialization }
AcDSLRV64GAssembler class >> initialize [
	"AcDSLAssemblerGenerator generate: self"
]

{ #category : #accessing }
AcDSLRV64GAssembler class >> isa [
	^ AcProcessorDescriptions riscv64
]
