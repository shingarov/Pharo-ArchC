Class {
	#name : #AIMM,
	#superclass : #AcAsmOperandModifier,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #disassembling }
AIMM class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f [
	| rotAndImm rot imm |
	anOperandInstantiation operands = #('rotate' 'imm8') asOrderedCollection
		ifFalse: [self error: 'Modifier "imm(aimm)" can only be used with rotate+imm8'].
	rotAndImm := anOperandInstantiation inEnvironment: e format: f.
	rot := rotAndImm first value.
	imm := 24 zeros, (rotAndImm second toBitVector: 8).
	imm := (imm bitRotateRight: rot*2) simplify.
	"to my (bgs) taste, a rather non-orthogonal convention that aimm is always signed"
	aWriteStream nextPutAll: imm signedValue asString
]

{ #category : #'rotation encoding' }
AIMM class >> encodeImm: a32bitInteger [
	"ARM: If a32bitInteger can be encoded as a rotated imm8,
	answer an Array with: rotate with: imm8; if not, raise Unrepresentable."
	0 to: 15 do: [ :rotate |
		| imm8 |
		imm8 := self encodeImm: a32bitInteger asRotation: rotate*2.
		imm8 notNil ifTrue: [ ^Array with: rotate with: imm8 ].
	].
	UnrepresentableOperand signal
]

{ #category : #private }
AIMM class >> encodeImm: a32bitInteger asRotation: shamt [
	"ARM: If a32bitInteger can be encoded as an imm8
	rotated right by shamt, answer imm8; if not, answer nil."
	| bv mask |
	mask := (16rFF toBitVector: 32) bitRotateRight: shamt.
	mask := mask simplify bitInvert simplify.
	bv := a32bitInteger toBitVector: 32.
	(bv & mask) value = 0 ifFalse: [ ^nil ].
	^(bv bitRotateLeft: shamt) value

]

{ #category : #'rotation encoding' }
AIMM class >> imm8Of: a32bitInteger [
	^(self encodeImm: a32bitInteger) second
]

{ #category : #'rotation encoding' }
AIMM class >> rotationOf: a32bitInteger [
	^(self encodeImm: a32bitInteger) first
]

{ #category : #API }
AIMM >> encodeInFields: fs "OperandInstantiation" accordingTo: format [
	x isString
		ifTrue: [ 	^Dictionary new
			at: 'rotate' put: 'AIMM rotationOf: (', x, ')';
			at: 'imm8' put: 'AIMM imm8Of: (', x, ')';
			yourself ]
		ifFalse: [ ^Dictionary new
			at: 'rotate' put: (AIMM rotationOf: x);
			at: 'imm8' put: (AIMM imm8Of: x);
			yourself ]

]
