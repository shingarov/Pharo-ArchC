Class {
	#name : #AcRISCVInstructionDissection,
	#superclass : #Object,
	#instVars : [
		'address',
		'instruction'
	],
	#category : #'ArchC-Extras-SmalltalkX-VDB'
}

{ #category : #'instance creation' }
AcRISCVInstructionDissection class >> for: aProcessorInstruction [
	^ self new
		setInstruction: aProcessorInstruction;
		yourself.
]

{ #category : #accessing }
AcRISCVInstructionDissection >> address [
	^ address
]

{ #category : #accessing }
AcRISCVInstructionDissection >> address:anInteger [
	address := anInteger.
]

{ #category : #accessing }
AcRISCVInstructionDissection >> branchTarget [
	"Return and address of next instruction if branch is taken.
	 Assumes that this instruction is a branch instruction."

	(instruction format name = 'Type_B' or:[ instruction format name = 'Type_J' ]) ifTrue: [
		| target |

		target := ((instruction field: 'imm4') , (instruction field: 'imm3') , (instruction field: 'imm2') , (instruction field: 'imm1')) << 1.
		target := target simplify.
		target isSymbolic ifFalse: [
			^ address + target signedValue.
		].
	].

	^ nil

	"Created: / 16-08-2018 / 10:33:29 / Jan Vrany <jan.vrany@fit.cvut.cz>"
	"Modified (comment): / 16-08-2018 / 14:03:27 / Jan Vrany <jan.vrany@fit.cvut.cz>"
]

{ #category : #testing }
AcRISCVInstructionDissection >> isBranch [
	"Return `true` is this instruction is some sort of branch instruction."
	^ instruction format name = 'Type_B'
		or:[ instruction format name = 'Type_J' 
			or: [ instruction name = 'jalr' ] ]

	"Created: / 03-07-2018 / 14:39:33 / Jan Vrany <jan.vrany@fit.cvut.cz>"
	"Modified (comment): / 16-08-2018 / 14:02:04 / Jan Vrany <jan.vrany@fit.cvut.cz>"
]

{ #category : #testing }
AcRISCVInstructionDissection >> isReturn [
	"Return `true` is this instruction is a return"
	^ instruction name = 'jalr' 
		and: [ (instruction fieldValue: 'rd') = 0
			and:[ (instruction fieldValue: 'rs1') = 1
				and:[ (instruction fieldValue: 'imm') = 0 ] ] ]

	"Created: / 03-07-2018 / 14:39:26 / Jan Vrany <jan.vrany@fit.cvut.cz>"
	"Modified (comment): / 16-08-2018 / 14:02:32 / Jan Vrany <jan.vrany@fit.cvut.cz>"
]

{ #category : #initialization }
AcRISCVInstructionDissection >> setInstruction: aProcessorInstruction [
	self assert: instruction isNil.
	instruction := aProcessorInstruction
]
