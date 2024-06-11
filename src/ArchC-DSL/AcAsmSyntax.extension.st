Extension { #name : #AcAsmSyntax }

{ #category : #'*ArchC-DSL' }
AcAsmSyntax >> assembleDSL: mnemonic operands: operandList [
	| operandIdx environment insn reloc |

	self assert: format operands size == format operands size.

	environment := Dictionary new.
	operandIdx := 1.
	format mnemonic isTextChunk ifFalse: [ 
		"Mnemonic is composed from text and mapped values, for example in POWER
		 'bc%[lk]%[aa]' or in ARM 'ldm%cond%lstype'. Handle this case here."

		(format mnemonic assembler parse: mnemonic) do: [:operandValue |
			| operandDef  |

			operandDef := self operands at: operandIdx.
			environment addAll: (operandDef asOperandInstantiation encodeValue: operandValue
									  accordingTo: instruction format).
			operandIdx := operandIdx + 1.  
		].
	].

	operandList with: format operands  do: [:operandValue :operandFormat |
		self assert: operandValue isAcDSLMemRef == operandFormat isMemRefChunk.

		"FIXME: this is not the best thing to to, we need to come up with nicer,
		 more extensible code! But for now it will do."
		operandValue isAcDSLMemRef ifTrue: [ 
			| offsetDef offsetMod baseDef baseMod |

			offsetDef := self operands at: operandIdx.
			offsetMod := operandFormat offset modifier.

			baseDef := self operands at: operandIdx + 1.
			baseMod := operandFormat base modifier.

			environment addAll: (offsetDef asOperandInstantiation encodeValue: (offsetMod new x: operandValue offset)
									  accordingTo: instruction format).
			environment addAll: (baseDef asOperandInstantiation encodeValue: (baseMod new x: operandValue base)
									  accordingTo: instruction format).

			operandIdx := operandIdx + 2.
		] ifFalse: [
			| operandDef operandModifier  |

			operandDef := self operands at: operandIdx.
			operandModifier := operandFormat modifier.

			environment addAll: (operandDef asOperandInstantiation encodeValue: (operandModifier new x: operandValue)
									  accordingTo: instruction format).

			operandIdx := operandIdx + 1.
		].    
	].
	self assert: operandIdx = (self operands size + 1).

	self constraints keysAndValuesDo: [:operandDef :operand |  
		environment addAll: (operandDef asOperandInstantiation encodeValue: operand
								  accordingTo: instruction format)
	]. 
	insn := self instruction inEnvironment: environment.
	reloc := operandList relocation.
	reloc notNil ifTrue: [
		insn relocation: operandList relocation
	].
	^ insn
]
