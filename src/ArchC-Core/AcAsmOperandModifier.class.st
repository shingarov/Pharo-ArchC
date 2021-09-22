Class {
	#name : #AcAsmOperandModifier,
	#superclass : #Object,
	#instVars : [
		'x'
	],
	#category : #'ArchC-Core-Parsing'
}

{ #category : #API }
AcAsmOperandModifier >> encodeInFields: fs accordingTo: format [
	self subclassResponsibility 
]

{ #category : #accessing }
AcAsmOperandModifier >> x [
	^ x
]

{ #category : #accessing }
AcAsmOperandModifier >> x: anObject [
	x := anObject
]
