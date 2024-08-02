Class {
	#name : #'R_RISCV_PCREL_HI20',
	#superclass : #AcRelocation,
	#pools : [
		'AcIntLimits',
		'AcRISCVISALimits'
	],
	#category : #'ArchC-RISCV-Relocations'
}

{ #category : #queries }
R_RISCV_PCREL_HI20 class >> isValidForInstruction: insn [
	^ insn format name = 'Type_U'
]

{ #category : #'processing - simplified' }
R_RISCV_PCREL_HI20 >> calculateS: s A: a P: p [
	"
	https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-elf.adoc#relocations

	High 20 bits of 32-bit PC-relative reference.

	"
	| v hi20 lo12  |

	v := s + a - p.

	(v between: INT32_MIN and: INT32_MAX) ifFalse:[ ^ AddressOutOfRange ].

	hi20 := v & (UINT32_MAX >> RISCV_IMM_BITS << RISCV_IMM_BITS).
	lo12 := v & (UINT32_MAX << RISCV_IMM_BITS) bitInvert32.

	(lo12 & (1 << (RISCV_IMM_BITS - 1))) ~~ 0 ifTrue: [
		hi20 := hi20 + (1 << RISCV_IMM_BITS).
	].
	"This is PITA! Here we have to convert unsigned
	 hi and lo to signed values!"
	hi20 := hi20 > INT32_MAX ifTrue: [ hi20 - (1 << 32) ] ifFalse: [ hi20 ].

	^ hi20 >> (32 - RISCV_BIGIMM_BITS)
]

{ #category : #'processing - simplified' }
R_RISCV_PCREL_HI20 >> fixup: memory at: address with: value [
	| code imms |

	imms := ByteArray new: 4.
	imms unsignedLongAt: 1 put: (value << RISCV_BIGIMM_SHIFT) & UINT32_MAX.

	code := memory copyFrom: address to: address + 4"U-type" - 1.
	code := code bitOr: imms.
	memory replaceFrom: address to: address + 4"U-Type" - 1 with: code.
	"
	AcProcessorDescriptions riscv64 decode: code
	"

]
