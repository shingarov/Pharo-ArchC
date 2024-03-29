Class {
	#name : #AcAssemblerTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #accessing }
AcAssemblerTest class >> resources [
	^ Array with: AcProcessorDescriptionsResource

]

{ #category : #common }
AcAssemblerTest >> isa: aSymbol assemble: source operandKeys: keys shouldBe: values [
	| pdl result actual expected |
	pdl := AcProcessorDescriptions perform: aSymbol.
	result := pdl assembler parse: source.
	actual := result allBindingValues.
	expected := Dictionary newFromKeys: keys andValues: values.
	self assert: actual equals: expected
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
AcAssemblerTest >> testADDI [
	self
		isa: #powerpc
		assemble: 'addi 1, 2, 3'
		operandKeys:  #(  opcd  rt  ra  d  )
		shouldBe:     #(  14    1   2   3  ).

]

{ #category : #powerpc }
AcAssemblerTest >> testADDIoutOfRange [
	self
		isa: #powerpc
		assemble: 'addi 1, 2, 65540'
		operandKeys:  #(  opcd  rt  ra  d  )
		shouldBe:     #(  14    1   2   4  ).

]

{ #category : #powerpc }
AcAssemblerTest >> testADDwithSpacesOrNot [
	self
		isa: #powerpc
		assemble: '     add   1,    2,3'
		operandKeys:  #(  opcd  rt  ra  rb  oe  xos   rc  )
		shouldBe:     #(  31    1   2   3   0   266   0   ).

]

{ #category : #arm }
AcAssemblerTest >> testAdd3nonrotated [
	self
		isa: #armv5
		assemble: 'addeq sp, sp, #1'
		operandKeys:  #(  op  func1  cond   s   rotate  rd   rn  imm8  )
		shouldBe:     #(  1   4      0      0   0       13   13  1     ).

]

{ #category : #powerpc }
AcAssemblerTest >> testB [
	self
		isa: #powerpc
		assemble: 'b 1234'
		operandKeys:  #(opcd  aa  lk  li     )
		shouldBe:     #(18    0   0   308    ).  "<-- 308 = 1234 >> 2. This is because low 2 bits of jump offset are not encoded."
]

{ #category : #powerpc }
AcAssemblerTest >> testBC [
	self
		isa: #powerpc
		assemble: 'bc 4, 2, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    0   0   4   0     2      308    ).  "<-- 308 = 1234 >> 2. This is because low 2 bits of jump offset are not encoded."

	self
		isa: #powerpc
		assemble: 'bne 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    0   0   4   0     2      308    ).  

	self
		isa: #powerpc
		assemble: 'bne cr3, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    0   0   4   3     2      308    ).
]

{ #category : #powerpc }
AcAssemblerTest >> testBCA [
	self
		isa: #powerpc
		assemble: 'bca 4, 2, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    1   0   4   0     2      308    ).  "<-- 308 = 1234 >> 2. This is because low 2 bits of jump offset are not encoded."

	self
		isa: #powerpc
		assemble: 'bnea 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    1   0   4   0     2      308    ).  

	self
		isa: #powerpc
		assemble: 'bnea cr3, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    1   0   4   3     2      308    ).  

	self
		isa: #powerpc
		assemble: 'bnea cr3, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    1   0   4   3     2      308    ).
]

{ #category : #powerpc }
AcAssemblerTest >> testBCL [
	self
		isa: #powerpc
		assemble: 'bcl 4, 2, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    0   1   4   0     2      308    ).  "<-- 308 = 1234 >> 2. This is because low 2 bits of jump offset are not encoded."

	self
		isa: #powerpc
		assemble: 'bnel 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    0   1   4   0     2      308    ).  

	self
		isa: #powerpc
		assemble: 'bnel cr3, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    0   1   4   3     2      308    ).  

	self
		isa: #powerpc
		assemble: 'bnel cr3, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    0   1   4   3     2      308    ).
]

{ #category : #powerpc }
AcAssemblerTest >> testBCLA [
	self
		isa: #powerpc
		assemble: 'bcla 4, 2, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    1   1   4   0     2      308    ).  "<-- 308 = 1234 >> 2. This is because low 2 bits of jump offset are not encoded."

	self
		isa: #powerpc
		assemble: 'bnela 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    1   1   4   0     2      308    ).  

	self
		isa: #powerpc
		assemble: 'bnela cr3, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    1   1   4   3     2      308    ).  

	self
		isa: #powerpc
		assemble: 'bnela cr3, 1234'
		operandKeys:  #(opcd  aa  lk  bo  bi_cf bi_cb  bd     )
		shouldBe:     #(16    1   1   4   3     2      308    ).
]

{ #category : #powerpc }
AcAssemblerTest >> testExpressionImm [
	| pdl instr binary concretePart offset |
	pdl := AcProcessorDescriptions powerpc.
	pdl instructionAt: 'lbzu'.
	instr := pdl assembler parse: 'lbzu 1, {x+y} (2)'.
	binary := instr binaryEncoding.
	concretePart := (binary copyFrom: 31 to: 16) simplify.
	self assert: concretePart equals: 16r8c22.
	offset := (binary copyFrom: 15 to: 0) simplify.
	self assert: offset isSymbolic.
	self assert: offset isLeaf. "let 'x+y' not fool you: this is the name of the constant"
	self assert: offset sym equals: 'x+y'.

]

{ #category : #powerpc }
AcAssemblerTest >> testLBZU1 [
	self
		isa: #powerpc
		assemble: 'lbzu 1,1234 (2      )'
		operandKeys:  #(  opcd  rt  ra  d     )
		shouldBe:     #(  35    1   2   1234  ).

]

{ #category : #powerpc }
AcAssemblerTest >> testLBZU2 [
	self
		isa: #powerpc
		assemble: 'lbzu 1,1234@l (   2)'
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

{ #category : #arm }
AcAssemblerTest >> testLdrPCRELNegative [
	self
		isa: #armv5
		assemble: 'ldr ip, -52'
		operandKeys:  #(  op  b  l   p  cond   u   w   rd   rn  imm12  )
		shouldBe:     #(  2   0  1   1  14     0   0   12   15  52     ).

]

{ #category : #arm }
AcAssemblerTest >> testLdrPCRELPositive [
	self
		isa: #armv5
		assemble: 'ldr ip, 52'
		operandKeys:  #(  op  b  l   p  cond   u   w   rd   rn  imm12  )
		shouldBe:     #(  2   0  1   1  14     1   0   12   15  52     ).

]

{ #category : #powerpc }
AcAssemblerTest >> testSC [
	self
		isa: #powerpc
		assemble: 'sc'
		operandKeys:  #(opcd  lev   )
		shouldBe:     #(17    0     ).

]

{ #category : #powerpc }
AcAssemblerTest >> testSC1 [
	self
		isa: #powerpc
		assemble: 'sc 1'
		operandKeys:  #(opcd  lev   )
		shouldBe:     #(17    1     ).

]

{ #category : #powerpc }
AcAssemblerTest >> testTRAP [
	| result |

	result := AcProcessorDescriptions powerpc assembler parse: 'trap'. "XO1 type"
	self assert: result binaryEncoding equals: 16r7FE00008.
	self assert: result disassemble equals: 'trap'.

	result := AcProcessorDescriptions powerpc assembler parse: 'tw 31,0,0'. 
	self assert: result binaryEncoding equals: 16r7FE00008.                       
	self assert: result disassemble equals: 'trap'.

	result := AcProcessorDescriptions powerpc assembler parse: 'tweq 0,1'. 
	self assert: result binaryEncoding equals: 16r7c800808.                       
	self assert: result disassemble equals: 'tweq 0, 1'.    

	result := AcProcessorDescriptions powerpc assembler parse: 'tw 4,0,1'. 
	self assert: result binaryEncoding equals: 16r7c800808.                       
	self assert: result disassemble equals: 'tweq 0, 1'.    

	"trap never"
	result := AcProcessorDescriptions powerpc assembler parse: 'twi 0,0,0x48'.
	self assert: result binaryEncoding equals: 16r0c000048.
	self assert: result disassemble equals: 'twi 0x0, 0, 0x48'
]
