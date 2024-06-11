Class {
	#name : #'R_RISCV_CALL_PLT',
	#superclass : #AcRelocation,
	#pools : [
		'AcIntLimits',
		'AcRISCVISALimits'
	],
	#category : #'ArchC-RISCV-Relocations'
}

{ #category : #queries }
R_RISCV_CALL_PLT class >> isValidForInstruction: insn [
	^ insn name = 'auipc'
]

{ #category : #'processing - simplified' }
R_RISCV_CALL_PLT >> calculateS: s A: a P: p [
	"
	https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-elf.adoc#relocations

	32-bit PC-relative function call, macros call, tail (PIC)
	"
	| v |

	v := s + a - p.

	(v between: INT32_MIN and: INT32_MAX) ifFalse:[
		"Target symbol is outside 32bit range, request PLT entry."

		| plte |

		plte := AcRelocationRequestPLTEntry query: self.
		v := plte value + a - p.
		(v between: INT32_MIN and: INT32_MAX) ifFalse:[
			"PLT still out of range?"
			^ AddressOutOfRange
		]
	].

	^ v
]

{ #category : #'processing - simplified' }
R_RISCV_CALL_PLT >> fixup: memory at: address with: value [
	| lo hi code imms |

	lo := value & (UINT32_MAX << RISCV_IMM_BITS) bitInvert32.
	hi := value & (UINT32_MAX << RISCV_IMM_BITS).

	(lo & (1 << (RISCV_IMM_BITS - 1))) ~~ 0 ifTrue: [
		hi := hi + (1 << RISCV_IMM_BITS).
	].

	imms := ByteArray new: 8.
	imms unsignedLongAt: 1 put: hi & UINT32_MAX.
	imms unsignedLongAt: 5 put: (lo << RISCV_IMM_SHIFT) & UINT32_MAX bigEndian: false.

	code := memory copyFrom: address to: address + 4"auipc" + 4"jalr" - 1.
	code := code bitOr: imms.
	memory replaceFrom: address to: address + 4"auipc" + 4"jalr" - 1 with: code.
	"
	AcProcessorDescriptions riscv64 decode: code
	"
]
