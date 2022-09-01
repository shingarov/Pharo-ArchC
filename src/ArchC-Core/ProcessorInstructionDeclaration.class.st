"
I represent an instruction where only ""constant"" fields, such as the opcode, are known.
NB: This class is an abstract template from which ProcessorInstructions are instantiated.
It is not, however, ""purely abstract"", because its instances exist -- they are values in the ""instructions"" Dictionary in the PDL.
However, even when an instruction is instantiated as ""fully ungrounded"", it is an instance of ProcessorInstruction.
"
Class {
	#name : #ProcessorInstructionDeclaration,
	#superclass : #AcInstruction,
	#instVars : [
		'name',
		'format',
		'internalBindings',
		'syntax',
		'isa'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> addSyntax: aMnemonicSpec [ 
	syntax isNil ifTrue: [
		syntax := Array with: aMnemonicSpec
	] ifFalse: [
		syntax := syntax copyWith: aMnemonicSpec
	].
]

{ #category : #queries }
ProcessorInstructionDeclaration >> alwaysFitsEncoding: aBitVector [
	"Answer true if the argument, `aBitVector`, is always a valid encoding of
	 receiver.

	 The meaning of this, is straightforward if `aBitVector` is concrete.

	 If `aBitVector` is symbolic, answer true unless `aBitVector` is inconsistent with
	 the receiver's encoding schema.  In other words, answer true if every interpretation
	 of variables in `aBitVector` makes a valid encodinf of the the receiver.

	 Care must be taken that client code does not try to intern names
	 used by instruction operands."
	
	| encodingIsCorrect  myUnknowns  solver  answer |

	"Short-circuit the check of instruction bit-widths do not
	 match - then it cannot possibly match."
	self format bitWidth ~~ aBitVector length ifTrue: [
		^ false
	].
	encodingIsCorrect := self binaryEncoding eq: aBitVector.
	myUnknowns := self binaryEncoding variables asArray.
	myUnknowns notEmpty ifTrue: [
		encodingIsCorrect := encodingIsCorrect exists: myUnknowns
	].
	solver := Z3Solver new.
	[
		answer := solver isValid: encodingIsCorrect
	] ensure: [ solver del. ].
	^ answer
]

{ #category : #converting }
ProcessorInstructionDeclaration >> as: instructionClass [
	| insn |

	self assert: (instructionClass includesBehavior: self class).

	insn := instructionClass new.
	(1 to: self class instSize) do: [:i | 
		| v |

		v := self instVarAt: i.
		(v isCollection and: [ v isString not ]) ifTrue: [ 
			v := v copy.
		].
		insn instVarAt: i put: v.
	].
	^ insn
]

{ #category : #assertions }
ProcessorInstructionDeclaration >> assertInvariants [
	self assert: name notNil.
	self assert: isa notNil.
	self assert: self format notNil.
	self assert: internalBindings isEmptyOrNil not
		 description: 'At least opcode must be specified'.
	self assert: (isa instructionFormats includes: self format).
	self assert: (isa instructions includes: self).

	internalBindings keysDo: [ :bitField |
		self assert: (self format bitFields contains: [:each | each key = bitField])
			 description: 'Instruction format '' , format name , '' has not bitfield '' , bitField , ''!'.
	].

	"ProcessorInstruction >> #disassemble requires syntax formats to be sorted
	 by increaring number of operands (in assembly language, that is, a comma-separated 
	 list of operands following mnemonic). Check that.

	 Note, that some instruction may have no syntax defined, hence the nil-check.
	"
	syntax notNil ifTrue: [
		1 to: syntax size - 1 do: [:i | 
			self assert: ((syntax at: i) isMoreOrEquallySpecificThan: (syntax at: i + 1))
		].
	].
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> binaryEncoding [
	^format binaryEncoding inEnvironment: internalBindings
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> bitWidth [
	"Answer the width of instructions in bits."

	^ self format bitWidth
]

{ #category : #'encoding / decoding' }
ProcessorInstructionDeclaration >> decodeBits: aBitVector [
	(self alwaysFitsEncoding: aBitVector) ifFalse: [ ^nil ].
	^self isa grounder ground: self using: aBitVector
]

{ #category : #disassembly }
ProcessorInstructionDeclaration >> externalBindingBits [
	"Answer the total number of bits in external-bound operands.
	This does NOT mean operands whose value we don't yet know,
	e.g. an RA register-number operand is still external even if
	we may already know which register it is."
	| sum |
	sum := 0.
	format bitFields do: [ :ass |
		(ass key isString and: (internalBindings includesKey: ass key) not) ifTrue: [ sum := sum + ass value abs ]].
	^sum
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> format [
	^ format

]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> format: anObject [
	format := anObject
]

{ #category : #converting }
ProcessorInstructionDeclaration >> inEnvironment: env [
	^self isa grounder ground: self using: (self binaryEncoding inEnvironment: env)
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> internalBindings [
	^ internalBindings
]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> internalBindings: aDictionary [
	internalBindings := aDictionary

]

{ #category : #accessing }
ProcessorInstructionDeclaration >> isa [
	^ isa
]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> isa: anAcProcessorDescription [
	isa := anAcProcessorDescription.

	format isString ifTrue: [ 
		format := isa instructionFormats at: format
	].     
	syntax notNil ifTrue: [ 
		syntax withIndexDo: [ :mnemonicSpecOrString :index |
			mnemonicSpecOrString isString ifTrue: [ 
				| mnemonicSpecSource mnemonicSpec |

				mnemonicSpecSource := mnemonicSpecOrString allButLast allButFirst.
				mnemonicSpec := (AcSetAsmParser pdl: isa) parse: mnemonicSpecSource.
				mnemonicSpec source: mnemonicSpecSource.
				mnemonicSpec instruction: self.
				syntax at: index put: mnemonicSpec.
				isa addSyntax: mnemonicSpec assembler                  
			].
		].
		syntax sort: [ :a :b | a isMoreOrEquallySpecificThan: b  ]
	].
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> mnemonics [
	"Return all mnemonics (as array of strings) defined by this format. 
	 See AcAsmFormat >> #mnemonicsInto: for details."

	| mnemonics |

	mnemonics := Set new.
	self mnemonicsInto: mnemonics.
	^ mnemonics

	"
	((AcProcessorDescriptions reset; armv5) instructionAt: 'add1') mnemonics
	((AcProcessorDescriptions reset; riscv) instructionAt: 'addi') mnemonics
	"
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> mnemonicsInto: aSet [
	"Add all mnemonics for this instruction into given set.
	 See AcAsmFormat >> #mnemonicsInto: for details."

	self syntax do: [:each | each mnemonicsInto: aSet ]
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> name [
	^ name
]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> name: anObject [
	name := anObject
]

{ #category : #GT }
ProcessorInstructionDeclaration >> nameForInspector [
	^self name
]

{ #category : #'as yet unclassified' }
ProcessorInstructionDeclaration >> opcode [
	^internalBindings at: isa opcdFieldName 
]

{ #category : #queries }
ProcessorInstructionDeclaration >> possiblyFitsEncoding: aBitVector [ 
	"Answer true if the argument, `aBitVector`, can possibly be valid encoding
	 of the receiver.

	 The meaning of this, is straightforward if `aBitVector` is concrete.

	 If `aBitVector` is symbolic, answer true unless `aBitVector` is inconsistent with
	 the receiver's encoding schema.  In other words, answer true if there exists (at least one) 
	 interpretation of `aBitVector`'s variables that makes `aBitVector` a correct encoding 
	 for the receiver.

	 Care must be taken that client code does not try to intern names
	 used by instruction operands."
	
	| solver  answer |

	solver := Z3Solver new.
	[
		solver assert: (self binaryEncoding eq: aBitVector).
		answer := solver check.
	] ensure: [ solver del. ].
	^ answer
]

{ #category : #printing }
ProcessorInstructionDeclaration >> printOn: aStream [ 
	aStream nextPutAll: self name.
	isa isNil ifTrue: [ 
		aStream nextPutAll: ' [as yet unknown architecture'
	] ifFalse: [ 
		aStream nextPutAll: ' [a '.
		aStream nextPutAll: isa architectureName.
	].
	aStream nextPutAll: ' instruction]'.

]

{ #category : #accessing }
ProcessorInstructionDeclaration >> syntax [
	"Return a collection of assembly syntax forms (as `AcAsmSyntax` instances)."

	syntax isNil ifTrue: [
		^ #()
	].
	^ syntax
]
