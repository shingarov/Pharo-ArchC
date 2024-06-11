Class {
	#name : #AcDSLSymbol,
	#superclass : #AcDSLOperand,
	#instVars : [
		'value',
		'relocation'
	],
	#category : #'ArchC-DSL'
}

{ #category : #'instance creation' }
AcDSLSymbol class >> value: anObject [
	^ self new value: anObject
]

{ #category : #arithmetic }
AcDSLSymbol >> + delta [
	self assert: relocation notNil.
	self assert: delta isInteger.

	relocation addend: relocation addend + delta
]

{ #category : #arithmetic }
AcDSLSymbol >> - delta [
	self assert: relocation notNil.
	self assert: delta isInteger.

	relocation addend: relocation addend - delta
]


{ #category : #conversion }
AcDSLSymbol >> asString [
	^ value asString
]

{ #category : #testing }
AcDSLSymbol >> isAcDSLSymbol [
	^ true
]

{ #category : #'printing & storing' }
AcDSLSymbol >> printOn: aStream [
	value printOn: aStream
]

{ #category : #accessing }
AcDSLSymbol >> relocation [
	^ relocation
]

{ #category : #accessing }
AcDSLSymbol >> relocation: anAcRelocation [
	self assert: anAcRelocation isAcRelocation.

	relocation := anAcRelocation

]

{ #category : #conversion }
AcDSLSymbol >> toBitVector: xlen [
	^ value toBitVector: xlen
]

{ #category : #conversion }
AcDSLSymbol >> toInt [
	^ value toInt
]

{ #category : #initialization }
AcDSLSymbol >> value: aStringOrSymbol [
	self assert: value isNil.
	self assert: aStringOrSymbol notNil.

	value := aStringOrSymbol
]
