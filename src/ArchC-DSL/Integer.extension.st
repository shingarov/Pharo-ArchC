Extension { #name : #Integer }

{ #category : #'*ArchC-DSL' }
Integer >> asAcDSLOperand [
	^ AcDSLImmediate value: self

	"Created: / 05-10-2021 / 13:08:03 / Jan Vrany <jan.vrany@labware.com>"
]
