Class {
	#name : #'R_RISCV_PCREL_LO12',
	#superclass : #AcRelocation,
	#pools : [
		'AcIntLimits',
		'AcRISCVISALimits'
	],
	#category : #'ArchC-RISCV-Relocations'
}

{ #category : #queries }
R_RISCV_PCREL_LO12 class >> isAbstract [
	"Return if this class is an abstract class.
	 True is returned here for myself only; false for subclasses.
	 Abstract subclasses must redefine this again."

	^ self == R_RISCV_PCREL_LO12.
]

{ #category : #queries }
R_RISCV_PCREL_LO12 class >> isValidForInstruction: insn [
	^ insn format name = 'Type_I' or: [ insn format name = 'Type_S' ]
]

{ #category : #accessing }
R_RISCV_PCREL_LO12 >> addend: anInteger [
	self assert: anInteger = 0 description: 'the addend must be 0'.
	super addend: anInteger.
]

{ #category : #'processing - simplified' }
R_RISCV_PCREL_LO12 >> calculateS: s A: a P: p [
	self shouldNotImplement
]

{ #category : #processing }
R_RISCV_PCREL_LO12 >> fixup: memory symbols: symbols relocations: relocations [
	"
	https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-elf.adoc#relocations

	High 20 bits of 32-bit PC-relative reference.

	NOTE: when calculating value, we have to use symbol and relocation
	position of corresponding R_RISCV_*_HI20 relocation, hence we cannot
	use simplified processing and have to override this method.
	"
	| hi20reloc s g a p v lo12 |

	(symbols includesKey: symbol) ifFalse: [
		"This is a failure because the real symbol is the one associated with
		 corresponding R_RISCV_*_HI20 relocation."
		AcRelocationFailed new
			relocation: self;
			signal: 'Relocation symbol not found!'.
		^ self
	].
	(relocations includesKey: self) ifFalse: [
		AcRelocationFailed new
			relocation: self;
			signal: 'Relocation position is not known!'. "This should not happen!"
		^ self
	].

	hi20reloc := relocations keyAtValue: (symbols at: symbol) ifAbsent: [ nil ].
	hi20reloc isNil ifTrue: [
		AcRelocationFailed new
			relocation: self;
			signal: 'Invalid ', self class name , ' relocation, no corresponding R_RISCV_*_HI20 Relocation!'. "This should not happen!"
		^ self
	].
	({ R_RISCV_PCREL_HI20 .  R_RISCV_GOT_HI20 } includes: hi20reloc class) ifFalse: [
		AcRelocationFailed new
			relocation: self;
			signal: 'Invalid ', self class name , ' relocation, must be paired with R_RISCV_*_HI20 Relocation!'. "This should not happen!"
		^ self
	].
	(symbols includesKey: hi20reloc symbol) ifFalse: [
		AcRelocationSymbolUnresolved new
			relocation: self;
			signal: 'Relocation symbol is unresolved (symbol address is not known)'.
		^ self
	].

	hi20reloc class == R_RISCV_GOT_HI20 ifTrue: [
		g := (AcRelocationRequestGOTEntry query:hi20reloc) value. "Position of GOT entry (G + GOT in spec)"
		a := hi20reloc addend.                 "Addend field in the relocation entry associated with the symbol"
		p := relocations at: hi20reloc.        "Position of the relocation"

		v := g + a - p.
	] ifFalse: [
		s := symbols at: hi20reloc symbol.     "Value of the symbol in the symbol table"
		a := hi20reloc addend.                 "Addend field in the relocation entry associated with the symbol"
		p := relocations at: hi20reloc.        "Position of the relocation"

		v := s + a - p.
	].


	(v between: INT32_MIN and: INT32_MAX) ifFalse:[
		AcRelocationOverflow new
			relocation: self;
			signal.
		^ self.
	].

	lo12 := v & ((UINT32_MAX << RISCV_IMM_BITS) bitInvert32).

	self fixup: memory at: (relocations at: self) with: lo12
]
