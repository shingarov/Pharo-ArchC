Class {
	#name : #'R_RISCV_64',
	#superclass : #AcRelocation,
	#pools : [
		'AcIntLimits'
	],
	#category : #'ArchC-RISCV-Relocations'
}

{ #category : #queries }
R_RISCV_64 class >> isValidForInstruction: insn [
	^ insn class == AcInt64
		and: [ insn isa architectureName = 'riscv64' ]
]

{ #category : #'processing - simplified' }
R_RISCV_64 >> calculateS: s A: a P: p [
	"
	https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-elf.adoc#relocations

	64-bit relocation

	"
	| v |

	v := s + a.

	(v between: UINT64_MIN and: UINT64_MAX) ifFalse:[ ^ AddressOutOfRange ].

	^ v
]

{ #category : #'processing - simplified' }
R_RISCV_64 >> fixup: memory at: address with: value [
	| addr |

	addr := ByteArray new: 8.
	addr unsignedLongLongAt: 1 put: value.

	memory replaceFrom: address to: address + 8 - 1 with: addr.
]
