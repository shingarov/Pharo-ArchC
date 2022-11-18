Extension { #name : #SequenceableCollection }

{ #category : '*ArchC-DSL' }
SequenceableCollection >> asAcDSLOperandList [
	^ AcDSLOperandList withAll: self
]
