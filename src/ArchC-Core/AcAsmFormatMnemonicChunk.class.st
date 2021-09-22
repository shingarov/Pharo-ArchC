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
	subchunks do:[:each | each disassembleTo: aWriteStream operands: ops inEnvironment: e ]

]

{ #category : #'printing & storing' }
AcAsmFormatMnemonicChunk >> unparseOn: aStream [            
	subchunks do: [:each | each unparseOn: aStream ]
]
