Class {
	#name : #AcDSLRegister,
	#superclass : #AcDSLOperand,
	#instVars : [
		'value'
	],
	#category : #'ArchC-DSL'
}

{ #category : #'instance creation' }
AcDSLRegister class >> value: anAcAsmMapEntry [
	^ self new value: anAcAsmMapEntry
]

{ #category : #accessing }
AcDSLRegister >> name [
	^ value name
]

{ #category : #'printing & storing' }
AcDSLRegister >> printOn: aStream [
	aStream nextPutAll: value name
]

{ #category : #conversion }
AcDSLRegister >> toBitVector: xlen [
	^ value toBitVector: xlen
]

{ #category : #conversion }
AcDSLRegister >> toInt [
	^ value toInt
]

{ #category : #initialization }
AcDSLRegister >> value: anAcAsmMapEntry [
	self assert: value isNil.
	self assert: anAcAsmMapEntry notNil.

	value := anAcAsmMapEntry
]