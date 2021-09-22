Class {
	#name : #AcAsmFormat,
	#superclass : #AcAsmFormatChunk,
	#instVars : [
		'mnemonic',
		'operands'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'API - assembly' }
AcAsmFormat >> assembler [
	operands isEmpty ifTrue: [ 
		^ (#space asParser star , mnemonic assembler)  ==> [ :nodes | nodes second ]
	] ifFalse: [ 
		^ (#space asParser star , mnemonic assembler , #space asParser plus , operands assembler) ==> [ :nodes | nodes second , nodes fourth ]
	].

]

{ #category : #'API - disassembly' }
AcAsmFormat >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	mnemonic disassembleTo: aWriteStream operands: ops inEnvironment: e.
	operands notEmpty ifTrue: [
		aWriteStream space.
		operands disassembleTo: aWriteStream operands: ops inEnvironment: e.
	]

]

{ #category : #accessing }
AcAsmFormat >> instruction: aProcessorInstructionDeclaration [
	super instruction: aProcessorInstructionDeclaration.
	mnemonic notNil ifTrue: [ 
		mnemonic instruction: aProcessorInstructionDeclaration.
	].
	operands notNil ifTrue: [ 
		operands instruction: aProcessorInstructionDeclaration
	].
]

{ #category : #accessing }
AcAsmFormat >> mnemonic [
	^ mnemonic

]

{ #category : #accessing }
AcAsmFormat >> mnemonic:anAcAsmFormatChunk [
	mnemonic := anAcAsmFormatChunk.

]

{ #category : #accessing }
AcAsmFormat >> operands [
	^ operands

]

{ #category : #accessing }
AcAsmFormat >> operands:aSequenceableCollection [
	operands := aSequenceableCollection.
]

{ #category : #'printing & storing' }
AcAsmFormat >> unparseOn: aStream [
	mnemonic unparseOn: aStream.
	operands notEmpty ifTrue: [ 
		aStream space.
		operands unparseOn: aStream
	].
]
