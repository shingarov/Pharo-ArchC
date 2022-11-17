Class {
	#name : #AcDSLOperandList,
	#superclass : #Array,
	#type : #variable,
	#category : #'ArchC-DSL'
}

{ #category : #adding }
AcDSLOperandList >> , anotherOperand [
	^ self copyWith: anotherOperand asAcDSLOperand
]

{ #category : #converting }
AcDSLOperandList >> asAcDSLOperandList [
	^ self
]
