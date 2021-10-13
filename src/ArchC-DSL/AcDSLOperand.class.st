Class {
	#name : #AcDSLOperand,
	#superclass : #Object,
	#category : #'ArchC-DSL'
}

{ #category : #adding }
AcDSLOperand >> , anotherOperand [
	^ AcDSLOperandList with: self with: anotherOperand asAcDSLOperand
]

{ #category : #conversion }
AcDSLOperand >> asAcDSLOperand [
	^ self
]

{ #category : #testing }
AcDSLOperand >> isAcDSLSymbol [
	^ false
]
