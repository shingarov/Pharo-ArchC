"
From the point of view of assembly syntax, each instruction
comes in a few ""variant mnemonic forms"".  Say, if there are 100
instructions and each has 3 mnemonic variants, the whole grammar
will consist of a choice of 300 form parsers.

Each form is a sequence of chunks.  Chunks work at the last stage
of the target-agnostic pipeline, i.e. the actual assembly/disassembly.
"
Class {
	#name : #AcAsmFormatChunk,
	#superclass : #Object,
	#instVars : [
		'instruction'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'API - assembly' }
AcAsmFormatChunk >> assembler [ 
	self subclassResponsibility 
]

{ #category : #'API - disassembly' }
AcAsmFormatChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	self subclassResponsibility 
]

{ #category : #'API - disassembly' }
AcAsmFormatChunk >> immExpression [
	^${ asParser, (PPPredicateObjectParser anyExceptAnyOf: #($})) star flatten, $} asParser
	==> [ :expr | expr second "the string inside {...} will become the variable name" ]
]

{ #category : #accessing }
AcAsmFormatChunk >> instruction [
	^ instruction
]

{ #category : #accessing }
AcAsmFormatChunk >> instruction: anObject [
	instruction := anObject
]
