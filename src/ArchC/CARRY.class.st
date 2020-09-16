"
Carry from the lower to the upper half of the address, as described in the ""Note about the [c] option of the H modifier"" on p.14 in v1.5 of The ArchC Assembler Generator Reference Manual.

As of today, I don't do anything, instead adapting to Cog design where all this is managed by the OutOfLineLiteralsManager.
"
Class {
	#name : #CARRY,
	#superclass : #AsmOperandModifier,
	#category : #'ArchC-Parsing'
}

{ #category : #disassembling }
CARRY class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f [
	| subfieldValues immValue |
	subfieldValues := anOperandInstantiation inEnvironment: e format: f.
	subfieldValues size = 1 ifFalse: [ self error ].
	immValue := subfieldValues first value.
	aWriteStream nextPutAll: '0x'.
	immValue printOn: aWriteStream base: 16 showRadix: false
]
