Class {
	#name : #BIMM16,
	#superclass : #AcAsmOperandModifier,
	#category : #'ArchC-RISCV-Parsing'
}

{ #category : #API }
BIMM16 >> encodeInFields: fs accordingTo: format [
	^ self encode: self x >> 1 inFields: fs accordingTo: format

]
