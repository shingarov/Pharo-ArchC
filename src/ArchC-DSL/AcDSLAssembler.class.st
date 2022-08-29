Class {
	#name : #AcDSLAssembler,
	#superclass : #Object,
	#instVars : [
		'memory'
	],
	#category : #'ArchC-DSL'
}

{ #category : #accessing }
AcDSLAssembler class >> isa [
	^ self subclassResponsibility
]

{ #category : #'instance creation' }
AcDSLAssembler class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #emitting }
AcDSLAssembler >> append: mnemonic operands: operands [
	| insn |

	insn := self class isa assembleDSL: mnemonic operands: operands.
	memory append: insn.
	^ insn.
]

{ #category : #accessing }
AcDSLAssembler >> grounder: anInstructionGrounder [
	self isa grounder: anInstructionGrounder
]

{ #category : #initialization }
AcDSLAssembler >> initialize [
	"Invoked when a new instance is created."

	memory := AcDSLCodeBuffer new

	"  super initialize.   -- commented since inherited method does nothing"
]

{ #category : #accessing }
AcDSLAssembler >> isa [
	^ self class isa
]

{ #category : #accessing }
AcDSLAssembler >> memory [
	^ memory
]
