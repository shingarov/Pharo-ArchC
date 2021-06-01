Class {
	#name : #NoOperandModifier,
	#superclass : #AsmOperandModifier,
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

{ #category : #API }
NoOperandModifier >> encodeBitVector: v inFields: fields accordingTo: format [ 
	| thisField thisWidth thisBV restFields rest restBV |
	"Fields go in order starting with MSB, ending with LSB."
	fields size = 1 ifTrue: [ 
		"induction base"
		^Dictionary new
			at: fields first 
			put: v;
			yourself
	].
	thisField := fields last.
	thisWidth := format widthOf: thisField.
	thisBV := v copyFrom: thisWidth - 1 to: 0.
	restBV := v copyFrom: v length - 1 to: thisWidth.
	restFields := fields allButLast.
	rest := self encodeBitVector: restBV simplify inFields: restFields accordingTo: format.
	rest at: thisField put: thisBV.
	^rest
]

{ #category : #API }
NoOperandModifier >> encodeInFields: fs accordingTo: format [
	| width bv |
	fs isMultiField ifFalse: [ ^fs encodeSimpleValue: self x ].
	width := fs widthAccordingTo: format.
	bv := self x toBitVector: width.
	^self encodeBitVector: bv
		inFields: fs operands 
		accordingTo: format
]
