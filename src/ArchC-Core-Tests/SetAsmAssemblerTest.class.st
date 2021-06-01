Class {
	#name : #SetAsmAssemblerTest,
	#superclass : #TestCaseWithZ3Context,
	#category : #'ArchC-Core-Tests'
}

{ #category : #common }
SetAsmAssemblerTest >> mnemonic: setAsm disassemble: source operandKeys: keys shouldBe: values [
	| result expected |
	result := setAsm assembler parse: source.
	expected := Dictionary newFromKeys: keys andValues: values.
	self assert: result allBindingValues equals: expected 
	
	
]

{ #category : #'tests - arm' }
SetAsmAssemblerTest >> testANDGTS [
	| and1 mn rrxSetAsm |
	and1 := AcProcessorDescriptions armv5 instructionAt: 'and1'.
	mn := and1 mnemonics.
	self assert: mn size equals: 3. 
	
	rrxSetAsm := and1 mnemonics detect: [ :m | (m source indexOfSubCollection: 'rrx') > 0 ].
	self mnemonic: rrxSetAsm
		disassemble:  'andgts sp, lr, pc, rrx'   "cond, s, rd, rn, rm, shift=3, shiftamount=0"
		operandKeys:  #(shiftamount rn s op subop1 cond rd func1 shift rm)
		shouldBe:     #(0           14 1 0  0      12   13 0     3     15).
					  "             lr s           gt   sp             pc  "
]

{ #category : #'tests - arm' }
SetAsmAssemblerTest >> testANDS [
	| and1 mn rrxSetAsm |
	and1 := AcProcessorDescriptions armv5 instructionAt: 'and1'.
	mn := and1 mnemonics.
	self assert: mn size equals: 3. 
	
	rrxSetAsm := and1 mnemonics detect: [ :m | (m source indexOfSubCollection: 'rrx') > 0 ].
	self mnemonic: rrxSetAsm
		disassemble:  'ands sp, lr, pc, rrx' "cond, s, rd, rn, rm, shift=3, shiftamount=0"
		operandKeys:  #(shiftamount rn s op subop1 cond rd func1 shift rm)
		shouldBe:     #(0           14 1 0  0      14   13 0     3     15).
				   "             lr s           --   sp             pc  "
]

{ #category : #'tests - powerpc' }
SetAsmAssemblerTest >> testLbzuPPC1 [
	| lbzu setAsm thisParser result bindings |
	lbzu := AcProcessorDescriptions powerpc instructionAt: 'lbzu'.
	self assert: lbzu mnemonics size equals: 2.
	setAsm := lbzu mnemonics detect: [ :m | (m source includes: $@) not ].
	thisParser := setAsm assembler.
	result := thisParser parse: 'lbzu 1, 1234 (2)'.
	bindings := result allBindingValues.
	self assert: (bindings at: 'd') equals: 1234.
]

{ #category : #'tests - powerpc' }
SetAsmAssemblerTest >> testLbzuPPC2 [
	| lbzu setAsm thisParser result bindings |
	lbzu := AcProcessorDescriptions powerpc instructionAt: 'lbzu'.
	self assert: lbzu mnemonics size equals: 2.
	setAsm := lbzu mnemonics detect: [ :m | m source includes: $@ ].
	thisParser := setAsm assembler.
	result := thisParser parse: 'lbzu 1, 1234@l(2)'.
	bindings := result allBindingValues.
	self assert: (bindings at: 'd') equals: 1234.	
]

{ #category : #'tests - powerpc' }
SetAsmAssemblerTest >> testTrapPPC [
	| tw trapSetAsm thisParser result |
	tw := AcProcessorDescriptions powerpc instructionAt: 'tw'.
	trapSetAsm := tw mnemonics detect: [ :m | m source beginsWith: '"tr' ].
	thisParser := trapSetAsm assembler.
	result := thisParser parse: 'trap'.
	self assert: result binaryEncoding equals: 16r7FE00008 
	
	
]

{ #category : #'tests - powerpc' }
SetAsmAssemblerTest >> testTwlgtPPC [
	| tw trapSetAsm thisParser result |
	tw := AcProcessorDescriptions powerpc instructionAt: 'tw'.
	self assert: tw mnemonics size equals: 2.
	trapSetAsm := tw mnemonics detect: [ :m | m source beginsWith: '"tw' ].
	thisParser := trapSetAsm assembler.
	result := thisParser parse: 'twlgt 1, 2'.
	self mnemonic: trapSetAsm
		disassemble:  'twlgt 1, 2'
		operandKeys:  #(  opcd  ra  rb  to  xog )
		shouldBe:     #(  31    1   2   1   4   ).

]

{ #category : #'tests - powerpc' }
SetAsmAssemblerTest >> testXxor_PPC [
	| xxor setAsm x |
	xxor := AcProcessorDescriptions powerpc instructionAt: 'xxor_'.
	setAsm := xxor mnemonics anyOne.
	x := setAsm assembler parse: 'xor. 5, 6, 7'.
	self assert: x name equals: 'xxor_'.
	self assert:  (x fieldValue: 'ra') equals: 5.
	self assert:  (x fieldValue: 'rs') equals: 6.
	self assert:  (x fieldValue: 'rb') equals: 7.
	
]
