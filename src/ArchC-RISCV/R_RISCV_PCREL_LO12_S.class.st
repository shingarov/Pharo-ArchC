Class {
	#name : #'R_RISCV_PCREL_LO12_S',
	#superclass : #'R_RISCV_PCREL_LO12',
	#pools : [
		'AcIntLimits',
		'AcRISCVISALimits'
	],
	#category : #'ArchC-RISCV-Relocations'
}

{ #category : #'processing - simplified' }
R_RISCV_PCREL_LO12_S >> fixup: memory at: address with: value [
	| imm1 imm2 code imms |

	imm1 := value                             & (UINT32_MAX << RISCV_S_TYPE_IMM1_BITS) bitInvert32.
	imm2 := (value >> RISCV_S_TYPE_IMM1_BITS) & (UINT32_MAX << RISCV_S_TYPE_IMM2_BITS) bitInvert32.

	imms := ByteArray new: 4.
	imms unsignedLongAt: 1 put: ((imm2 << RISCV_S_TYPE_IMM2_SHIFT) | (imm1 << RISCV_S_TYPE_IMM1_SHIHT)) & UINT32_MAX bigEndian: false.

	code := memory copyFrom: address to: address + 4"I-type" - 1.
	code := code bitOr: imms.
	memory replaceFrom: address to: address + 4"I-type" - 1 with: code.
	"
	AcProcessorDescriptions riscv64 decode: code
	"
]
