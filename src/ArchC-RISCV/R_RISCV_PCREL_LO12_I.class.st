Class {
	#name : #'R_RISCV_PCREL_LO12_I',
	#superclass : #'R_RISCV_PCREL_LO12',
	#pools : [
		'AcIntLimits',
		'AcRISCVISALimits'
	],
	#category : #'ArchC-RISCV-Relocations'
}

{ #category : #'processing - simplified' }
R_RISCV_PCREL_LO12_I >> fixup: memory at: address with: value [
	| code imms |

	imms := ByteArray new: 4.
	imms unsignedLongAt: 1 put: (value << RISCV_IMM_SHIFT) & UINT32_MAX bigEndian: false.

	code := memory copyFrom: address to: address + 4"I-type" - 1.
	code := code bitOr: imms.
	memory replaceFrom: address to: address + 4"I-type" - 1 with: code.
	"
	AcProcessorDescriptions riscv64 decode: code
	"
]
