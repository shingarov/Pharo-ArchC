"
Test concretization of Cog-like operands in RTL notated using the <operands: #(x y z)> notation.
"
Class {
	#name : #RtlOperandConcretizationTest,
	#superclass : #TestCase,
	#instVars : [
		'operands'
	],
	#category : #'ArchC-Extras-Pharo-Tests'
}

{ #category : #compiler }
RtlOperandConcretizationTest class >> compiler [
	^ super compiler addPlugin: PDLOpalPlugin 
]

{ #category : #compiler }
RtlOperandConcretizationTest class >> template [ 
	^RtlOperandConcretizationTest >> #templateMethod 
]

{ #category : #instructions }
RtlOperandConcretizationTest >> MoveM16rR [
	<operands: #(destReg offset srcReg)>
	<mips: 'lhu {destReg}, {offset} ({srcReg})'> 
]

{ #category : #assembler }
RtlOperandConcretizationTest >> getOperand: j [
	^operands at: j
]

{ #category : #'z3 context' }
RtlOperandConcretizationTest >> setUp [
	Z3Context createGlobalContext.
	AcProcessorDescriptions reset.
	self class recompile
]

{ #category : #assembler }
RtlOperandConcretizationTest >> templateMethod [
	| instr theEnvironment |
	theEnvironment := Dictionary new .
	1. 2. 3. 4. 5. 6. 7. 8.
	instr := #theInstruction.
	^instr inEnvironment: theEnvironment
]

{ #category : #tests }
RtlOperandConcretizationTest >> testLHU [
	| encoding |
	operands := #(2 16r1234 1).
	encoding := self MoveM16rR.
	self assert: encoding size equals: 1.
	encoding := encoding first.
	"Type I: op:6 rs: 5 rt:5 imm:16:s"
	self assert: encoding equals: 16r94221234.
]
