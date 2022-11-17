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

{ #category : #conversion }
AcDSLOperand >> asAcDSLOperandList [
	^ AcDSLOperandList with: self
]

{ #category : #testing }
AcDSLOperand >> isAcDSLImmediate [
	^ false
]

{ #category : #testing }
AcDSLOperand >> isAcDSLMemRef [
	^ false
]

{ #category : #testing }
AcDSLOperand >> isAcDSLRegister [
	^ false
]

{ #category : #testing }
AcDSLOperand >> isAcDSLSymbol [
	^ false
]
