Extension { #name : #Object }

{ #category : #'*ArchC-DSL' }
Object >> asAcDSLOperand [
	self error: 'No automatic conversion to instruction operand'

	"Created: / 19-06-2024 / 12:09:42 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*ArchC-DSL' }
Object >> asAcDSLOperandList [
	^ AcDSLOperandList with: self asAcDSLOperand

	"
	1 asAcDSLOperandList
	(AcDSLSymbol value: 'xxx') asAcDSLOperandList
	"
]
