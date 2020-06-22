Class {
	#name : #AcAssemblerTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests'
}

{ #category : #common }
AcAssemblerTest >> isa: aSymbol assemble: source operandKeys: keys shouldBe: values [
	| pdl result expected |
	pdl := AcProcessorDescriptions perform: aSymbol.
	result := pdl assembler parse: source.
	expected := Dictionary newFromKeys: keys andValues: values.
	self assert: result allBindingValues equals: expected 
]

{ #category : #running }
AcAssemblerTest >> resetZ3Context [
	Z3Context createGlobalContext.
	AcProcessorDescriptions reset.
]

{ #category : #powerpc }
AcAssemblerTest >> testADD [
	self
		isa: #powerpc
		assemble: 'add 1, 2, 3'
		operandKeys:  #(  opcd  rt  ra  rb  oe  xos   rc  )
		shouldBe:     #(  31    1   2   3   0   266   0   ).

]

{ #category : #powerpc }
AcAssemblerTest >> testADD_ [
	self
		isa: #powerpc
		assemble: 'add 1, 2, 3'
		operandKeys:  #(  opcd  rt  ra  rb  oe  xos   rc  )
		shouldBe:     #(  31    1   2   3   0   266   0   ).

]

{ #category : #powerpc }
AcAssemblerTest >> testB [
	self
		isa: #powerpc
		assemble: 'b 1234'
		operandKeys:  #(opcd  aa  lk  li     )
		shouldBe:     #(18    0   0   1234   ).

]

{ #category : #powerpc }
AcAssemblerTest >> testExpressionImm [
	| pdl instr binary concretePart offset |
	pdl := AcProcessorDescriptions powerpc.
	instr := pdl assembler parse: 'lbzu 1, {x+y} (2)'.
	binary := instr binaryEncoding.
	concretePart := (binary copyFrom: 31 to: 16) simplify.
	self assert: concretePart equals: 16r8c22.
	offset := (binary copyFrom: 15 to: 0) simplify.
	self assert: offset isSymbolic.
	self assert: offset term isLeaf. "let 'x+y' not fool you: this is the name of the constant"
	self assert: offset sym equals: 'x+y'.
]

{ #category : #powerpc }
AcAssemblerTest >> testLBZU1 [
	self
		isa: #powerpc
		assemble: 'lbzu 1, 1234 (2)'
		operandKeys:  #(  opcd  rt  ra  d     )
		shouldBe:     #(  35    1   2   1234  ).

]

{ #category : #powerpc }
AcAssemblerTest >> testLBZU2 [
	self
		isa: #powerpc
		assemble: 'lbzu 1, 1234@l(2)'
		operandKeys:  #(  opcd  rt  ra  d     )
		shouldBe:     #(  35    1   2   1234  ).

]

{ #category : #sparc }
AcAssemblerTest >> testLDSB2 [
	self flag: #BOGUS_PDL.
	"self
		isa: #sparcv8
		assemble: 'ldsb [%fp], %sp'
		operandKeys:  #(     )
		shouldBe:     #(     ).
"
]

{ #category : #powerpc }
AcAssemblerTest >> testLIS [
	self
		isa: #powerpc
		assemble: 'lis 1, 1234@ha'
		operandKeys:  #(  opcd  rt  ra   d      )
		shouldBe:     #(  15    1   0    1234   ).

]

{ #category : #powerpc }
AcAssemblerTest >> testLISwithCarry [
	self
		isa: #powerpc
		assemble: 'lis 1, 1234'
		operandKeys:  #(  opcd  rt  ra   d      )
		shouldBe:     #(  15    1   0    1234   ).

]

{ #category : #ia32 }
AcAssemblerTest >> testNOP [
	| result |
	result := AcProcessorDescriptions x86 assembler parse: 'NOP'.
	self assert: result binaryEncoding equals: 16r90
]

{ #category : #'riscv-r32i' }
AcAssemblerTest >> testRiscvJAL [
	self
		isa: #riscv
		assemble: 'JAL $sp, 74565'
		operandKeys:  #(  op    rd   imm1  imm2  imm3  imm4  )
		shouldBe:     #(  111   14   837   0     36    0     ).
	
"16r12345  =   74565"
	self flag: #BOGUS "see TextDisassemblyTest>>testRiscvJAL"
]

{ #category : #powerpc }
AcAssemblerTest >> testTRAP [
	| result |
	result := AcProcessorDescriptions powerpc assembler parse: 'trap'. "XO1 type"
	self assert: result binaryEncoding equals: 16r7FE00008 
]
