Class {
	#name : #AsmOperandInstantiation,
	#superclass : #Object,
	#instVars : [
		'operands'
	],
	#category : #'ArchC-Core'
}

{ #category : #'instance creation' }
AsmOperandInstantiation class >> operands: opsArray [
	"See AcAsmOperandsParser>>operand.
	ops is essentially a lisp-like list represented in cons pairs.
	Here in Smalltalk, each pair is an Array with: car with: cdr.
	This representation is chosen because this is directly what
	comes out of the parser.
	"
	| car cdr |
	car := opsArray first.
	cdr := opsArray second.
	cdr isNil ifTrue: [ ^self singleOperand: car ].
	"This is for when the operand spans several fields.
	For example, on RISC-V:
	JAL rd, imm4+imm3+imm2+imm1"
	cdr := cdr second. "artefact of parsing"
	cdr operands addFirst: car.
	^cdr
]

{ #category : #'instance creation' }
AsmOperandInstantiation class >> singleOperand: op [
	^self new operands: (OrderedCollection with: op)
]

{ #category : #private }
AsmOperandInstantiation >> asOperandInstantiation [
	^self
]

{ #category : #private }
AsmOperandInstantiation >> encodeBitVector: v inFields: fields accordingTo: format [ 
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

{ #category : #private }
AsmOperandInstantiation >> encodeSimpleValue: v [
	^Dictionary new
		at: self operand put: v;
		yourself
]

{ #category : #private }
AsmOperandInstantiation >> encodeValue: value accoringTo: format [
	| width bv |
	self isMultiField ifFalse: [ ^self encodeSimpleValue: value ].
	width := self widthAccordingTo: format.
	bv := value asBitVector: width.
	^self encodeBitVector: bv
		inFields: self operands 
		accordingTo: format 
]

{ #category : #rewriting }
AsmOperandInstantiation >> inEnvironment: aDictionary format: f [
	^self operands collect: [ :subfield |
		| width v |
		width := f widthOf: subfield.
		v := aDictionary at: subfield.
		v asBitVector: width ]
]

{ #category : #testing }
AsmOperandInstantiation >> isMultiField [
	^self operands size ~= 1
]

{ #category : #accessing }
AsmOperandInstantiation >> operand [
	self isMultiField ifTrue: [ self error ].
	^self operands first
]

{ #category : #accessing }
AsmOperandInstantiation >> operands [
	^ operands
]

{ #category : #accessing }
AsmOperandInstantiation >> operands: anObject [
	operands := anObject
]

{ #category : #printing }
AsmOperandInstantiation >> printOn: aStream [
	aStream nextPutAll: self operands first.
	self isMultiField ifTrue: [ self printRestOfOperandsOn: aStream ]
]

{ #category : #printing }
AsmOperandInstantiation >> printRestOfOperandsOn: aStream [
	self operands allButFirst do: [ :field |
		aStream
			nextPut: $+;
			nextPutAll: field ].
]

{ #category : #private }
AsmOperandInstantiation >> widthAccordingTo: format [
	^self operands inject: 0 into: [ :soFar :currentField |
		soFar + (format widthOf: currentField)
	]
]
