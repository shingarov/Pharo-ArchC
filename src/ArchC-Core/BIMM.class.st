"
Branch offset on ARM
"
Class {
	#name : #BIMM,
	#superclass : #AcAsmOperandModifier,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #API }
BIMM class >> decode: bitfields fromFields: operandInstantiation accordingTo: format [
	^ (operandInstantiation decode: bitfields accordingTo: format) << 2
]

{ #category : #API }
BIMM >> encodeInFields: fs accordingTo: format [
	| width value |

	width := (fs widthAccordingTo: format).
	value := self x toBitVector: width.
	^ self encode: (value bitShiftRightArithmetic: 2) inFields: fs accordingTo: format
]
