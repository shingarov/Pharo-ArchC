"
I represent an instruction where only ""constant"" fields, such as the opcode, are known.
NB: This class is an abstract template from which ProcessorInstructions are instantiated.
It is not, however, ""purely abstract"", because its instances exist -- they are values in the ""instructions"" Dictionary in the PDL.
However, even when an instruction is instantiated as ""fully ungrounded"", it is an instance of ProcessorInstruction.
"
Class {
	#name : #ProcessorInstructionDeclaration,
	#superclass : #Object,
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

{ #category : #solving }
ProcessorInstructionDeclaration >> alwaysFitsBinary: aBV [
	"Answer true if the argument, aBV, can possibly be the binary encoding
	of the receiver.
	
	The meaning of this, is straightforward if aBV is concrete.
	
	If aBV is symbolic, answer true unless aBV is inconsistent with
	the receiver's encoding schema.  In other words, answer true if there
	exists an interpretation of aBV's variables that makes aBV a correct
	encoding for the receiver.
	
	Care must be taken that client code does not try to intern names
	used by instruction operands."
	
	^self inEmptyEnvironment alwaysFitsBinary: aBV
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


{ #category : #solving }
ProcessorInstructionDeclaration >> canFitBinary: aBitVector [
	"Answer true if the argument, aBV, can possibly be the binary encoding
	of the receiver.
	
	The meaning of this, is straightforward if aBV is concrete.
	
	If aBV is symbolic, answer true unless aBV is inconsistent with
	the receiver's encoding schema.  In other words, answer true if there
	exists an interpretation of aBV's variables that makes aBV a correct
	encoding for the receiver.
	
	Care must be taken that client code does not try to intern names
	used by instruction operands."
	
	^self inEmptyEnvironment canFitBinary: aBitVector
]

{ #category : #disassembly }
ProcessorInstructionDeclaration >> decodeBits: aBitVector [
	"Answer a copy of the receiver concretized down to be
	consistent with the binary encoding given by aBV.
	Answer nil if this is impossible, -- e.g., if the opcode
	contained in aBV is different from the receiver's opcode.
	
	The most straightforward scenario is when the receiver
	is an instruction declaration (i.e. none of the operands
	are known) and the argument is concrete (non-symbolic),
	resulting in a fully-grounded instruction; but this does
	not *necessarily* have to be the only possible scenario:
	some operands could be known already, and aBV could
	contain some unknown bits."
	aBitVector isAST ifFalse: [^self decode: (aBitVector toBitVector: self format width)].
	(self alwaysFitsBinary: aBitVector) ifFalse: [ ^nil ].
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

{ #category : #emitting }
ProcessorInstructionDeclaration >> inEmptyEnvironment [
	^self inEnvironment: Dictionary new
]

{ #category : #emitting }
ProcessorInstructionDeclaration >> inEnvironment: env [
	"Answer a ProcessorInstruction where the operands are bound according to env.
	It is not necessary to define values for ALL operands; if some operands are
	left unspecified, those bits in the emitted binary will be symbolic.
	NB: unlike #decode: which returns a model, this method's answer is the most general."
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
