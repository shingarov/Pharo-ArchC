Extension { #name : #String }

{ #category : #'*ArchC-DSL' }
String >> asAcDSLOperand [
	^ AcDSLSymbol value: self

	"Created: / 13-06-2024 / 17:26:26 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*ArchC-DSL' }
String >> asAcDSLOperandList [
	^ AcDSLOperandList with: self asAcDSLOperand

	"
	'ABCD' asAcDSLOperandList
	"
]
