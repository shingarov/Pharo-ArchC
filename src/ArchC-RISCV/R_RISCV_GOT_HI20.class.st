Class {
	#name : #'R_RISCV_GOT_HI20',
	#superclass : #AcRelocation,
	#pools : [
		'AcIntLimits',
		'AcRISCVISALimits'
	],
	#category : #'ArchC-RISCV-Relocations'
}

{ #category : #queries }
R_RISCV_GOT_HI20 class >> isValidForInstruction: insn [
	^ insn format name = 'Type_U'
]

{ #category : #'processing - simplified' }
R_RISCV_GOT_HI20 >> fixup: memory at: address with: value [
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

{ #category : #processing }
R_RISCV_GOT_HI20 >> fixup: memory symbols: symbols relocations: relocations [
	"
	https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-elf.adoc#relocations

	High 20 bits of 32-bit PC-relative GOT access, %got_pcrel_hi(symbol)

	NOTE: when calculating value, we have to ask for GOT entry address,
	hence we cannot use simplified processing and have to override
	this method.
	"

	| g a p v hi20 lo12 |

	(symbols includesKey: symbol) ifFalse: [
		AcRelocationSymbolUnresolved new
			relocation: self;
			signal: 'Relocation symbol is unresolved (symbol address is not known)'.
		^ self
	].
	(relocations includesKey: self) ifFalse: [
		AcRelocationFailed new
			relocation: self;
			signal: 'Relocation position is not known!'. "This should not happen!"
		^ self
	].


	g := (AcRelocationRequestGOTEntry query:self) value.
	a := addend.
	p := relocations at: self.

	v := g + a - p.
	(v between: INT32_MIN and: INT32_MAX) ifFalse: [
		AcRelocationOverflow new
			relocation: self;
			signal: 'GOT entry out of range!'.
		^ self
	].


	hi20 := v & (UINT32_MAX >> RISCV_IMM_BITS << RISCV_IMM_BITS).
	lo12 := v & (UINT32_MAX << RISCV_IMM_BITS) bitInvert32.

	(lo12 & (1 << (RISCV_IMM_BITS - 1))) ~~ 0 ifTrue: [
		hi20 := hi20 + (1 << RISCV_IMM_BITS).
	].
	"This is PITA! Here we have to convert unsigned
	 hi and lo to signed values!"
	hi20 := hi20 > INT32_MAX ifTrue: [ hi20 - (1 << 32) ] ifFalse: [ hi20 ].

	self fixup: memory at: p with: (hi20 >> (32 - RISCV_BIGIMM_BITS)       )
]
