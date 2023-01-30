"
AcAsmFormatChunk represents a part of assembly syntax format and
it is responsible for both assembling and disasembling it.

From the point of view of assembly syntax, each instruction
comes in a few ""variant mnemonic formats"". For example: 

 * the RISC-V `j` mnemonic is just an ""alias"" for `jal zero, offset`
 * the RISC-V `ret` mnemonic is just an ""alias"" for `jalr zero, ra, offset`
 * the POWER `trap` mnemonic is just an ""alias"" `tw 31, 0, 0`

Here, the (RISC-V) instruction `jal` would have associated two assembly
formats (instances of `AcAsmFormat`), one for `j` mnemonic and one for
`jal` mnemonic.

Each format is represented as a tree of `AcAsmFormatChunk` subclasses,
`AcAsmFormat` being alway the root.

"
Class {
	#name : #AcAsmFormatChunk,
	#superclass : #Object,
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcAsmFormatChunk class >> builtin: aString modifier: anAcAsmOperandModifier [
	^ AcAsmFormatBuiltinChunk new type: aString; modifier: anAcAsmOperandModifier

]

{ #category : #accessing }
AcAsmFormatChunk class >> builtins [
	^ #('%imm' '%exp' '%addr')
]

{ #category : #'instance creation' }
AcAsmFormatChunk class >> map: aString [
	^ AcAsmFormatMapChunk new name: aString

]

{ #category : #'instance creation' }
AcAsmFormatChunk class >> mnemonic: aSequenceableCollection [
	self assert: aSequenceableCollection isCollection.
	self assert: aSequenceableCollection notEmpty.
	aSequenceableCollection size == 1 ifTrue: [ ^aSequenceableCollection first ].
	^ AcAsmFormatMnemonicChunk new subchunks: aSequenceableCollection

]

{ #category : #'instance creation' }
AcAsmFormatChunk class >> mnemonic: anAcAsmFormatChunk modifier: anAcAsmFormatOperandsChunk [
	^ AcAsmFormat new mnemonic: anAcAsmFormatChunk; operands: anAcAsmFormatOperandsChunk

]

{ #category : #'instance creation' }
AcAsmFormatChunk class >> operands: anObject [
	self assert: anObject isCollection.
	^ AcAsmFormatOperandsChunk new subchunks: anObject

]

{ #category : #'instance creation' }
AcAsmFormatChunk class >> sequence: aSequenceableCollection [
	self assert: aSequenceableCollection isCollection.
	self assert: aSequenceableCollection notEmpty.
	aSequenceableCollection size == 1 ifTrue: [ ^aSequenceableCollection first ].
	^ AcAsmFormatSequenceChunk new subchunks: aSequenceableCollection

]

{ #category : #'instance creation' }
AcAsmFormatChunk class >> space: aStringOrCharacter [
	^ AcAsmFormatLiteralSpaceChunk new text: aStringOrCharacter asString

]

{ #category : #'instance creation' }
AcAsmFormatChunk class >> text: aStringOrCharacter [
	^ AcAsmFormatLiteralTextChunk new text: aStringOrCharacter asString

]

{ #category : #'API - assembly' }
AcAsmFormatChunk >> assembler [
	"Return an `PPParser` responsible for parsing this chunk. 
	 As a parse result the parser should return *an array* of
	 operand values."

	self subclassResponsibility 

]

{ #category : #'API - disassembly' }
AcAsmFormatChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	"Disassemble a chunk onto a stream according to given environment.
	 Returns
	  - `true` if chunk was successfully disassembled
	  - `false` otherwise.

	 Note, that some text may have been written to stream EVEN IF dissasembly
	 fails (and this method returned `false`)!
	"
	^ self subclassResponsibility
]

{ #category : #'parsing - private' }
AcAsmFormatChunk >> immExpression [
	^${ asParser, (PPPredicateObjectParser anyExceptAnyOf: #($})) star flatten, $} asParser
	==> [ :expr | expr second "the string inside {...} will become the variable name" ]
]

{ #category : #accessing }
AcAsmFormatChunk >> instruction: aProcessorInstructionDeclaration [
	"Nothing to do"
]

{ #category : #testing }
AcAsmFormatChunk >> isBuiltinChunk [
	"return false here; to be redefined in subclass(es)"

	^ false
]

{ #category : #testing }
AcAsmFormatChunk >> isMapChunk [
	^ false
]

{ #category : #testing }
AcAsmFormatChunk >> isMemRefChunk [
	^ false
]

{ #category : #testing }
AcAsmFormatChunk >> isTextChunk [
	^ false
]

{ #category : #accessing }
AcAsmFormatChunk >> modifier [
	^ NoOperandModifier
]

{ #category : #'printing & storing' }
AcAsmFormatChunk >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPut: $".
	self unparseOn: aStream.
	aStream nextPut: $".
	aStream nextPut: $).
]

{ #category : #'printing & storing' }
AcAsmFormatChunk >> unparseOn: aStream [
	"Print this chunk on `aStream` using the syntax recognized by AcAsmFormatParser."

	self subclassResponsibility
]
