Class {
	#name : #AcDSLMemRef,
	#superclass : #AcDSLOperand,
	#instVars : [
		'base',
		'offset'
	],
	#category : #'ArchC-DSL'
}

{ #category : #'instance creation' }
AcDSLMemRef class >> base: base offset: offset [
	^ self new
		base: base;
		offset: offset;
		yourself.
]

{ #category : #accessing }
AcDSLMemRef >> base [
	^ base
]

{ #category : #accessing }
AcDSLMemRef >> base:anAcDSLOperand [
	self assert: (anAcDSLOperand isAcDSLSymbol or: [anAcDSLOperand isAcDSLRegister]).
	base := anAcDSLOperand.
]

{ #category : #testing }
AcDSLMemRef >> isAcDSLMemRef [
	^ true
]

{ #category : #accessing }
AcDSLMemRef >> offset [
	^ offset
]

{ #category : #accessing }
AcDSLMemRef >> offset:anAcDSLOperand [
	self assert: (anAcDSLOperand isAcDSLSymbol or: [anAcDSLOperand isAcDSLImmediate]).
	offset := anAcDSLOperand.
]

{ #category : #'printing & storing' }
AcDSLMemRef >> printOn: aStream [
	base printOn: aStream.
	aStream nextPutAll: ' + '.
	offset printOn: aStream.
]
