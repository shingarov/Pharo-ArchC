Class {
	#name : #'R_RISCV_32',
	#superclass : #AcRelocation,
	#pools : [
		'AcIntLimits'
	],
	#category : #'ArchC-RISCV-Relocations'
}

{ #category : #queries }
R_RISCV_32 class >> isValidForInstruction: insn [
	 ^ insn class == AcInt32
		and: [ insn isa architectureName = 'riscv32' ]
]

{ #category : #'processing - simplified' }
R_RISCV_32 >> calculateS: s A: a P: p [
	"
	https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-elf.adoc#relocations

	32-bit relocation

	"
	| v |

	v := s + a.

	(v between: UINT32_MIN and: UINT32_MAX) ifFalse:[ ^ AddressOutOfRange ].

	^ v
]

{ #category : #'processing - simplified' }
R_RISCV_32 >> fixup: memory at: address with: value [
	| addr |

	addr := ByteArray new: 4.
	addr unsignedLongAt: 1 put: value.

	memory replaceFrom: address to: address + 4 - 1 with: addr.
]
