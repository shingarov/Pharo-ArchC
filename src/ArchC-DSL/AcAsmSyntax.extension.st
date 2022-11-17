Extension { #name : #AcAsmSyntax }

{ #category : #'*ArchC-DSL' }
AcAsmSyntax >> assembleDSL: mnemonic operands: operandList [
	| operandIdx environment |

	self assert: format operands size == format operands size.

	environment := Dictionary new.
	operandIdx := 1.
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
									  accoringTo: instruction format).
			environment addAll: (baseDef asOperandInstantiation encodeValue: (baseMod new x: operandValue base)
									  accoringTo: instruction format).

			operandIdx := operandIdx + 2.
		] ifFalse: [
			| operandDef operandModifier  |

			operandDef := self operands at: operandIdx.
			operandModifier := operandFormat modifier.

			environment addAll: (operandDef asOperandInstantiation encodeValue: (operandModifier new x: operandValue)
									  accoringTo: instruction format).

			operandIdx := operandIdx + 1.
		].    
	].
	self assert: operandIdx = (self operands size + 1).

	self constraints keysAndValuesDo: [:operandDef :operand |  
		environment addAll: (operandDef asOperandInstantiation encodeValue: operand
								  accoringTo: instruction format)
	]. 
	^self instruction inEnvironment: environment
]
