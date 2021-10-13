Class {
	#name : #AcDSLSymbol,
	#superclass : #AcDSLOperand,
	#instVars : [
		'value'
	],
	#category : #'ArchC-DSL'
}

{ #category : #'instance creation' }
AcDSLSymbol class >> value: anObject [
	^ self new value: anObject
]

{ #category : #testing }
AcDSLSymbol >> isAcDSLSymbol [
	^ true
]

{ #category : #'printing & storing' }
AcDSLSymbol >> printOn: aStream [
	value printOn: aStream
]

{ #category : #conversion }
AcDSLSymbol >> toBitVector: xlen [
	^ value asString toBitVector: xlen
]

{ #category : #conversion }
AcDSLSymbol >> toInt [
	^ value asString toInt
]

{ #category : #initialization }
AcDSLSymbol >> value: aStringOrSymbol [
	self assert: value isNil.
	self assert: aStringOrSymbol notNil.

	value := aStringOrSymbol
]
