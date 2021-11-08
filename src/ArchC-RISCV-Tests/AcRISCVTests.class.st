Class {
	#name : #AcRISCVTests,
	#superclass : #TestCase,
	#instVars : [
		'pdl'
	],
	#category : #'ArchC-RISCV-Tests'
}

{ #category : #accessing }
AcRISCVTests class >> resources [
	^ Array with: AcProcessorDescriptionsResource
]

{ #category : #running }
AcRISCVTests >> setUp [
	super setUp.
	pdl := AcProcessorDescriptions riscv64
]

{ #category : #'tests - RISC-V' }
AcRISCVTests >> testRiscvADD [
	| instr operands grounded |

	instr := pdl instructionAt: #add.
	operands := Dictionary new
		at: 'rs1' put: 1;
		at: 'rs2' put: 2;
		at: 'rd'  put: 3;
		yourself.
	grounded := instr inEnvironment: operands.
	self assert: grounded emit32 equals: 2r00000000001000001000000110110011.

	instr := pdl decode: 16r00000893. "addi r17 <- 0"
	self assert: instr name equals: 'addi'.
	self assert: (instr fieldValue: 'rs1') equals: 0.
	self assert: (instr fieldValue: 'rd')  equals: 17.
	self assert: (instr fieldValue: 'opcode') equals: 19.
]

{ #category : #'tests - RISC-V' }
AcRISCVTests >> testRiscvADDI [
	| insn |

	insn := pdl assembler parse: 'addi a4, a5, 0'.
	self assert: insn asByteArray = #[ 16r13 16r87 16r07 16r00 ]
]

{ #category : #'tests - RISC-V' }
AcRISCVTests >> testRiscvAUIPC [
	| insn |

	insn := pdl assembler parse: 'auipc a0, 0xfab00'.
	self assert: insn emit32 = 16rfab00517.
]

{ #category : #'tests - RISC-V' }
AcRISCVTests >> testRiscvBNE [
	| insn |

	insn := pdl assembler parse: 'bne  a5,  a3    , -12'.
	self assert: insn asByteArray equals: #[ 16re3 16r9a 16rd7 16rfe ].
	self assert: insn disassemble equals: 'bne a5, a3, -12'.

	"Test jump to label"
	insn := pdl assembler parse: 'bne  a5, a3, {label}'.
	self assert: insn disassemble equals: 'bne a5, a3, {label}'.
]

{ #category : #'tests - RISC-V' }
AcRISCVTests >> testRiscvEBREAK [
	| insn |

	insn := pdl assembler parse: 'ebreak'.
	self assert: insn asByteArray = #[115 0 16 0]
]

{ #category : #'tests - RISC-V' }
AcRISCVTests >> testRiscvJAL [
	| insn |

	insn := pdl assembler parse: 'jalr ra, a0, 0x8'.
	self assert: insn emit32 equals: 16r008500e7.

	insn := pdl decode: 16r008500e7 .
	"Dissasembly prints displacement as signed decimal since
	 in syntax format, %exp is used"
	self assert: insn disassemble equals: 'jalr ra, a0, 8'.
]

{ #category : #'tests - RISC-V' }
AcRISCVTests >> testRiscvJALR [
	| insn |

	insn := pdl assembler parse: 'jalr zero, ra, 0x0'.

	self assert: insn emit32 = 16r00008067.

	insn := pdl assembler parse: 'jalr ra, a0, 8'.
	self assert: insn emit32 = 16r008500e7.
]

{ #category : #'tests - RISC-V' }
AcRISCVTests >> testRiscvSLLI [
	| insn |

	insn := pdl assembler parse: 'slli zero, zero, 0x1f'.

	self assert: insn asByteArray = #[19 16 240 1]
]

{ #category : #'tests - RISC-V' }
AcRISCVTests >> testRiscvSRAI [
   | insn |

	insn := pdl assembler parse: 'srai zero, zero, 7'.

	self assert: insn asByteArray = #[16r13 16r50 16r70 16r40]
]
