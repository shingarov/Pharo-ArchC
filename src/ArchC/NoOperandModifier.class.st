Class {
	#name : #NoOperandModifier,
	#superclass : #AsmOperandModifier,
	#category : #'ArchC-Parsing'
}

{ #category : #disassembling }
NoOperandModifier class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f [
	| subfieldValues fullBitVector |
	subfieldValues := anOperandInstantiation inEnvironment: e format: f.
	fullBitVector := (BitVector concatAll: subfieldValues) simplify.
	aWriteStream nextPutAll: '0x'.
	fullBitVector value printOn: aWriteStream base: 16 showRadix: false
]
