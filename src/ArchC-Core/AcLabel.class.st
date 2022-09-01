Class {
	#name : #AcLabel,
	#superclass : #AcPseudoInstruction,
	#instVars : [
		'symbol'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcLabel class >> symbol: anObject [
	^ self new symbol: anObject
]

{ #category : #'encoding / decoding' }
AcLabel >> disassemble [
	^ symbol asString , ':'
]

{ #category : #testing }
AcLabel >> isLabelInstruction [
	^ true
]

{ #category : #accessing }
AcLabel >> name [
	^ '<label>'
]

{ #category : #accessing }
AcLabel >> symbol [
	^ symbol
]

{ #category : #accessing }
AcLabel >> symbol: anObject [
	symbol := anObject.
]
