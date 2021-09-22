Class {
	#name : #AcAsmOperandModifier,
	#superclass : #Object,
	#instVars : [
		'x'
	],
	#category : #'ArchC-Core-Parsing'
}

{ #category : #'printing & storing' }
AcAsmOperandModifier class >> unparseOn: aStream [
	"See AcAsmFormatChunk >> #unparseOn:"
	aStream nextPut: $(.
	aStream nextPutAll: self name asLowercase.
	aStream nextPut: $).

]

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
