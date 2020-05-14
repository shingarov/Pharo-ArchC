"
From the point of view of assembly syntax, each instruction
comes in a few ""variant mnemonic forms"".  Say, if there are 100
instructions and each has 3 mnemonic variants, the whole grammar
will consist of a choice of 300 form parsers.

Each form is a sequence of chunks.  Chunks work at the last stage
of the target-agnostic pipeline, i.e. the actual assembly/disassembly.
"
Class {
	#name : #AcMnemonicChunk,
	#superclass : #Object,
	#category : #'ArchC-Core'
}

{ #category : #'API - assembly' }
AcMnemonicChunk >> assembler [ 
	self subclassResponsibility 
]

{ #category : #'API - disassembly' }
AcMnemonicChunk >> disassembleTo: aWriteStream inEnvironment: e [
	self subclassResponsibility 
]
