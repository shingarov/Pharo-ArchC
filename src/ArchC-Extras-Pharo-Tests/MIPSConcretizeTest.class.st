Class {
	#name : #MIPSConcretizeTest,
	#superclass : #TestCase,
	#instVars : [
		'operands'
	],
	#category : #'ArchC-Extras-Pharo-Tests'
}

{ #category : #compiler }
MIPSConcretizeTest class >> compiler [
	^ super compiler addPlugin: PDLOpalPlugin 
]

{ #category : #assembly }
MIPSConcretizeTest >> MoveM16rR [
	<operands: #(destReg offset srcReg)>
	<mips: 'lhu {destReg}, {offset} ({srcReg})'> 
]

{ #category : #tests }
MIPSConcretizeTest >> getOperand: j [
	^operands at: j
]

{ #category : #tests }
MIPSConcretizeTest >> testLHU [
	| instr |
	operands := #(2 16r1234 1).
	instr := self MoveM16rR.
	"Type I: op:6 rs: 5 rt:5 imm:16:s"
	self assert: instr equals: 16r94221234.
]
