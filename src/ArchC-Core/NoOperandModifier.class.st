Class {
	#name : #NoOperandModifier,
	#superclass : #AcAsmOperandModifier,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #disassembling }
NoOperandModifier class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f [
	| subfieldValues fullBitVector |
	subfieldValues := anOperandInstantiation inEnvironment: e format: f.
	fullBitVector := (BitVector concatAll: subfieldValues) simplify.
	fullBitVector isSymbolic ifTrue: [
			aWriteStream nextPut: ${.
			aWriteStream nextPutAll: fullBitVector astToString.
			aWriteStream nextPut: $} 
	] ifFalse: [
		aWriteStream nextPutAll: '0x'.
		fullBitVector value printOn: aWriteStream base: 16 showRadix: false
	]

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
