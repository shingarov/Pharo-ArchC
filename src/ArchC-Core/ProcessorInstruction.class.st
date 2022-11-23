"
I am a CPU instruction.
I may be grounded to some degree or another -- i.e., some operands known and some not.
When the PDL spec is initially parsed, the ""instrictions"" Dictionary is filled with ""fully free"" instructions, i.e. only the constant fields (such as opcd) are known but none of the operands.  This does not, however, prevent the instruction from being emitted; if some operand is unknown, the corresponding bits in the binary encoding will be an algebraic variable.
"
Class {
	#name : #ProcessorInstruction,
	#superclass : #ProcessorInstructionDeclaration,
	#instVars : [
		'binaryEncoding'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #comparing }
ProcessorInstruction >> = another [
	self == another ifTrue: [^true].
	self class = another class ifFalse: [^false].
	^self binaryEncoding = another binaryEncoding
]

{ #category : #access }
ProcessorInstruction >> allBindingValues [
	| allBindings |
	allBindings := format bitFields
		reject: [ :bitField | bitField isFixedValue ]
		thenCollect: [ :bitField | bitField name -> (self fieldValue: bitField name) ].
	^Dictionary newFromAssociations: allBindings
]

{ #category : #accessing }
ProcessorInstruction >> binaryEncoding [
	binaryEncoding isNil ifTrue: [
		"
		Using `super binaryEncoding` is a temporary hack until
		we make (partially) grounded instruction and instruction
		declaration separate classes (which do not inherit from 
		each other).

		Here, `super binaryEncoding` will execute ProcessorInstructionDeclaration
		encoding which returns a binary encoding with opcode (and perhaps some
		other fields) concrete and the rest symbolic.

		This hack will wanish soon.
		"
		binaryEncoding := super binaryEncoding
	].
	^binaryEncoding
]

{ #category : #disassembly }
ProcessorInstruction >> disassemble [
	"Disassemble the receiver. If the receiver can be disassembled to (or assembled from)
	 using different (extended) mnemonics, use the most specific. 

	 For example, on PowerPC an unconditional trap instruction can be written as
	 `trap` or `tw 31, 0, 0`. In this case, this method will return `trap` as it
	 is most specific.

	 Similarly, for RISC-V, return from subroutine can be written either as
	 `jalr zero, ra, 0` or as `ret`. Again, `ret` wil be returned in this case.

	 By 'most specific' we mean the mnemonic that uses least operands.
	"
	| bindings |

	bindings := self allBindingValues.
	self syntax do: [:each |
		| disassembly |

		disassembly := each disassembleEnv: bindings.
		disassembly notNil ifTrue: [ 
			"Please note, that formats are kept sorted by number
			 of operands so if disassembles, we know it is the
			 most specific one. See 
					ProcessorInstructionDeclaration >> #isa:
					AcProcessorDescription >> #fillMnemonicsFrom:"
			^ disassembly 
		]
	].
	self error: 'Failed to disassemble'
]

{ #category : #'encoding / decoding' }
ProcessorInstruction >> emit32 [
	"Just making mischief.
	Some not-so-nice ISAs do not allow this (not that I care)."
	self assert: self bitWidth == 32.
	^self binaryEncoding value
]

{ #category : #'encoding / decoding' }
ProcessorInstruction >> emitOn: aStream [
	"Emit (encode) instruction on given (binary) stream. The instruction
	 must be fully grounded (that is: not symbolic) otherwise an error is
	 thrown.
	"
	self binaryEncoding toByteArrayEndian: self isa endian on: aStream
]

{ #category : #accessing }
ProcessorInstruction >> externalBindings [
	| externalBindings |
	externalBindings := Dictionary new.
	format bitFields do: [:bitfield | 
		(bitfield isFixedValue not 
			and: [ (internalBindings includesKey: bitfield name) not ]) 
				ifTrue: [
					externalBindings at: bitfield name put: (self fieldValue: bitfield name)
				].
	].
	^ externalBindings
]

{ #category : #access }
ProcessorInstruction >> field: fieldName [
	"Answer the value of the requested field, as a bit vector."
	^self binaryEncoding subrange: (self format bitRangeOfField: fieldName)
]

{ #category : #access }
ProcessorInstruction >> fieldValue: fieldName [
	"Answer the value of the requested field, as an Integer
	(observing two's complement if required)."
	| bitVector |
	bitVector := (self field: fieldName) simplify.
	^(format isSigned: fieldName)
		ifTrue: [ bitVector signedValue ]
		ifFalse: [ bitVector value ]
]

{ #category : #inspecting }
ProcessorInstruction >> inspectorExtraAttributes [
	"Smalltalk/X inspector extras"
	| attrs |

	attrs := super inspectorExtraAttributes.
	attrs at: '-encoding' put: [ String streamContents: [:s | self printEncodingOn: s]].
	attrs at: '-externalBindings' put: [self externalBindings].
	attrs at: '-allBindings' put: [self allBindingValues].
	^attrs
]

{ #category : #testing }
ProcessorInstruction >> isProcessorInstruction [
	^ true
]

{ #category : #printing }
ProcessorInstruction >> printEncodingOn: aStream [
	| bin idx |

	bin := String streamContents:[:b|self emit32 printOn:b paddedWith:$0 to:32 base:2].

	idx := 0.
	format bitFields do:[:field |
		aStream nextPutAll: (bin copyFrom: idx + 1 to: idx + field value abs).
		aStream space.
		idx := idx + field value abs
	].
	aStream cr.
	format bitFields do:[:field |
		| fieldName |

		fieldName := (field key size > field value abs) 
						ifTrue:[field key copyFrom: 1 to: field value abs]
						ifFalse:[ field key ].
		aStream nextPutAll: fieldName.
		aStream next: field value abs - fieldName size put: Character space.
		aStream space.
	].
]

{ #category : #printing }
ProcessorInstruction >> printOn: aStream [ 
	aStream nextPutAll: (self name); nextPutAll: ': '.
	aStream nextPutAll: self disassemble.

]

{ #category : #initialization }
ProcessorInstruction >> setBinaryEncoding: aBitVector [ 
	self assert: aBitVector isBitVector.
	self assert: aBitVector length == self format bitWidth.
	binaryEncoding := aBitVector
]
