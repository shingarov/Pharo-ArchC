Class {
	#name : #NoOperandModifier,
	#superclass : #AcAsmOperandModifier,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #API }
NoOperandModifier class >> decode: bitfields fromFields: operandInstantiation accordingTo: format [
	^ operandInstantiation decode: bitfields accordingTo: format
]

{ #category : #'printing & storing' }
NoOperandModifier class >> unparseOn: aStream [
	"See AcAsmFormatChunk >> #unparseOn:"

	"Intentionally left empty"

]

{ #category : #API }
NoOperandModifier >> encodeInFields: fs accordingTo: format [
	^ self encode: self x inFields: fs accordingTo: format

]

{ #category : #'printing & storing' }
NoOperandModifier >> unparseOn: aStream [
	"Intentionally left empty"

]
