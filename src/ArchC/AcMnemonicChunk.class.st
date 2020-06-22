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
	#instVars : [
		'instruction'
	],
	#category : #'ArchC-Core'
}

{ #category : #'API - assembly' }
AcMnemonicChunk >> assembler [ 
	self subclassResponsibility 
]

{ #category : #'API - disassembly' }
AcMnemonicChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	self subclassResponsibility 
]

{ #category : #'API - disassembly' }
AcMnemonicChunk >> immExpression [
	^${ asParser, ($} asParser not, #any asParser) star flatten, $} asParser ==> [ :expr | expr second "the string inside {...} will become the variable name" ]
]

{ #category : #accessing }
AcMnemonicChunk >> instruction [
	^ instruction
]

{ #category : #accessing }
AcMnemonicChunk >> instruction: anObject [
	instruction := anObject
]
