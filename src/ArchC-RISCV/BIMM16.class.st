Class {
	#name : #BIMM16,
	#superclass : #PCREL,
	#category : #'ArchC-RISCV-Parsing'
}

{ #category : #API }
BIMM16 class >> decode: bitfields fromFields: operandInstantiation accordingTo: format [
	^ (operandInstantiation decode: bitfields accordingTo: format) << 1
]

{ #category : #API }
BIMM16 >> encodeInFields: fs accordingTo: format [
	| width value |

	width := (fs widthAccordingTo: format).
	value := self x toBitVector: width.
	^ self encode: (value bitShiftRightArithmetic: 1) inFields: fs accordingTo: format
]
