Class {
	#name : #AsmOperandModifier,
	#superclass : #Object,
	#instVars : [
		'x'
	],
	#category : #'ArchC-Core-Parsing'
}

{ #category : #API }
AsmOperandModifier >> encodeInFields: fs accordingTo: format [
	self subclassResponsibility 
]

{ #category : #accessing }
AsmOperandModifier >> x [
	^ x
]

{ #category : #accessing }
AsmOperandModifier >> x: anObject [
	x := anObject
]
