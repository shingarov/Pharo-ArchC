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
	(mnemonic disassembleTo: aWriteStream operands: ops inEnvironment: e) ifFalse: [ 
		^ false
	].        
	operands notEmpty ifTrue: [
		aWriteStream space.
		(operands disassembleTo: aWriteStream operands: ops inEnvironment: e) ifFalse: [ 
			^ false
		].
	].
	^ true
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
AcAsmFormat >> mnemonicsInto: aSet [
	"Add all mnemonics (as strings) defined by this format into given
	 set.

	 Usually, each asm format defines one mnemonic but some ISAs
	 define multiple mnemonics in single asm format by means of 
	 maps. 

	 For example, consider ARMv5 ISA and 'add1' instruction format
	 'add%[cond]%sf %reg, %reg, %reg'. 
	 Then

		 (armv5 instructionAt: 'add1') mnemonicsInto: set

	 adds to the set following: 

		 #('addeq' 'addeqs' 'addne' 'addnes' ... 'addle' 'addles')

	"
	^ mnemonic mnemonicsInto: aSet
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
