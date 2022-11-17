Class {
	#name : #AcDSLImmediate,
	#superclass : #AcDSLOperand,
	#instVars : [
		'value'
	],
	#category : #'ArchC-DSL'
}

{ #category : #'instance creation' }
AcDSLImmediate class >> value: anInteger [
	^ self new value: anInteger
]

{ #category : #testing }
AcDSLImmediate >> isAcDSLImmediate [
	^ true
]

{ #category : #arithmetic }
AcDSLImmediate >> negated [
	^ self class value: value negated
]

{ #category : #'printing & storing' }
AcDSLImmediate >> printOn: aStream [
	value printOn: aStream
]

{ #category : #conversion }
AcDSLImmediate >> toBitVector: xlen [
	^ value toBitVector: xlen
]

{ #category : #conversion }
AcDSLImmediate >> toInt [
	^ value toInt
]

{ #category : #initialization }
AcDSLImmediate >> value: anInteger [
	self assert: value isNil.
	self assert: anInteger notNil.

	value := anInteger
]
