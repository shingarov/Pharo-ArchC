Extension { #name : #SequenceableCollection }

{ #category : #'*ArchC-DSL' }
SequenceableCollection >> asAcDSLOperandList [
	| operandList |

	operandList := AcDSLOperandList new: self size.
	1 to: self size do: [:i |
		operandList at: i put: (self at: i) asAcDSLOperand.
	].
	^ operandList.
]
