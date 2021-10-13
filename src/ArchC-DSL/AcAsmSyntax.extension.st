Extension { #name : #AcAsmSyntax }

{ #category : #'*ArchC-DSL' }
AcAsmSyntax >> assembleDSL: mnemonic operands: operandList [
	| environment |

	self assert: self operands size == operandList size.
	self assert: self operands size == format operands size.

	environment := Dictionary new.
	1 to: self operands size do: [:i |
		| operandDef operandModifier operandValue |

		operandDef := self operands at: i.
		operandModifier := (format operands at: i) modifier.
		operandValue := operandList at: i.

		environment addAll: (operandDef asOperandInstantiation encodeValue: (operandModifier new x: operandValue)
								  accoringTo: instruction format)

	].
	self constraints keysAndValuesDo: [:operandDef :operand |  
		environment addAll: (operandDef asOperandInstantiation encodeValue: operand
								  accoringTo: instruction format)
	]. 
	^self instruction inEnvironment: environment
]
