"
`AcAsmFormatMnemonicChunk` represent an instruction mnemonic when it consists
of mixture literal text and mapped values. 

For example, ARM (AArch32) specifies assembly syntax for - say - `andgt` and
`andlts` (an others) using single format definition

	and1.set_asm(""and%[cond]%sf %reg, %reg, %reg"", cond, s, rd, rn, rm, shiftamount=0, shift=0);

Note, that in cases where mnemonic is just a text, the `AcAsmFormat mnemonic` chunk is the 
corresponding `AcAsmFormatLiteralTextChunk` directly (this is very common)

"
Class {
	#name : #AcAsmFormatMnemonicChunk,
	#superclass : #AcAsmFormatCompositeChunk,
	#category : #'ArchC-Core-Core'
}

{ #category : #'API - assembly' }
AcAsmFormatMnemonicChunk >> assembler [
	subchunks isEmpty ifTrue: [ ^ nil asParser ==> [:ignored | #() ] ].

	^ (PPSequenceParser withAll: (subchunks collect: #assembler)) 
	==> [ :nodes | (nodes reject:#isEmpty) flattened ]

]

{ #category : #'API - disassembly' }
AcAsmFormatMnemonicChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	subchunks do:[:subchunk | 
		(subchunk disassembleTo: aWriteStream operands: ops inEnvironment: e) ifFalse:[ ^ false ] 
	].
	^ true
]

{ #category : #accessing }
AcAsmFormatMnemonicChunk >> mnemonicsInto: aSet [
	"See AcAsmFormat >> #mnemonicsInto:"

	| mnemonics |

	mnemonics := Set with:''.
	subchunks do: [:each | 
		each isTextChunk ifTrue: [ 
			mnemonics := mnemonics collect: [ :prefix | prefix , each text ].
		] ifFalse: [ 
			each isMapChunk ifTrue: [ 
				mnemonics := mnemonics collect: [ :prefix | each map forwardMap keys collect: [:sym | prefix , sym ] ].
				mnemonics := mnemonics flattened.
			] ifFalse: [ 
				self error: 'Not a text nor map chunk in mnemonic, should not happen!'
			].
		].
	].
	aSet addAll: mnemonics.

	"
	((AcProcessorDescriptions armv5) instructionAt: 'add1') mnemonics
	((AcProcessorDescriptions riscv) instructionAt: 'addi') mnemonics
	"
]

{ #category : #accessing }
AcAsmFormatMnemonicChunk >> subchunks:aSequenceableCollection [
	subchunks := aSequenceableCollection.
]

{ #category : #'printing & storing' }
AcAsmFormatMnemonicChunk >> unparseOn: aStream [            
	subchunks do: [:each | each unparseOn: aStream ]
]
