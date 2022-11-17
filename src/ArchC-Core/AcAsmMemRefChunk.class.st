Class {
	#name : #AcAsmMemRefChunk,
	#superclass : #AcAsmFormatChunk,
	#instVars : [
		'base',
		'offset'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcAsmMemRefChunk class >> base: base offset: offset [
	^ self new
		base: base;
		offset: offset;
		yourself.
]

{ #category : #'API - assembly' }
AcAsmMemRefChunk >> assembler [
	"Return an `PPParser` responsible for parsing this chunk. 
	 As a parse result the parser should return *an array* of
	 operand values."

	^ offset assembler , $( asParser trim , base assembler , $) asParser trim
		==> [ :nodes | Array with: nodes first first with: nodes third first ]
]

{ #category : #accessing }
AcAsmMemRefChunk >> base [
	^ base
]

{ #category : #accessing }
AcAsmMemRefChunk >> base:something [
	base := something.
]

{ #category : #'API - disassembly' }
AcAsmMemRefChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	"Disassemble a chunk onto a stream according to given environment.
	 Returns
	 - `true` if chunk was successfully disassembled
	 - `false` otherwise.
	 
	 Note, that some text may have been written to stream EVEN IF dissasembly
	 fails (and this method returned `false`)!"

	(offset disassembleTo: aWriteStream operands: ops inEnvironment: e) ifFalse: [ ^ false ].
	aWriteStream nextPut: $(.
	(base disassembleTo: aWriteStream operands: ops inEnvironment: e) ifFalse: [ ^ false ].
	aWriteStream nextPut: $).
	^ true
]

{ #category : #accessing }
AcAsmMemRefChunk >> instruction: aProcessorInstructionDeclaration [
	super instruction: aProcessorInstructionDeclaration.
	base instruction: aProcessorInstructionDeclaration.
	offset instruction: aProcessorInstructionDeclaration.
]

{ #category : #testing }
AcAsmMemRefChunk >> isMemRefChunk [
	^ true
]

{ #category : #accessing }
AcAsmMemRefChunk >> offset [
	^ offset
]

{ #category : #accessing }
AcAsmMemRefChunk >> offset:something [
	offset := something.
]

{ #category : #'printing & storing' }
AcAsmMemRefChunk >> unparseOn: aStream [
	"Print this chunk on `aStream` using the syntax recognized by AcAsmFormatParser."

	offset unparseOn: aStream.
	aStream nextPut: $(.
	base unparseOn: aStream.
	aStream nextPut: $).
]
