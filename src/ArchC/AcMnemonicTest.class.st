Class {
	#name : #AcMnemonicTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests'
}

{ #category : #'tests - instructions - ARM' }
AcMnemonicTest >> add1 [
	^AcProcessorDescriptions armv5 instructionAt: #add1
]

{ #category : #'tests - instructions - ARM' }
AcMnemonicTest >> add3 [
	^AcProcessorDescriptions armv5 instructionAt: #add3
]

{ #category : #'tests - instructions - PowerPC' }
AcMnemonicTest >> addi [
	^AcProcessorDescriptions powerpc instructionAt: #addi
]

{ #category : #'tests - instructions - ARM' }
AcMnemonicTest >> and1 [
	^AcProcessorDescriptions armv5 instructionAt: #and1
]

{ #category : #'tests - instructions - PowerPC' }
AcMnemonicTest >> bcctr [
	^AcProcessorDescriptions powerpc instructionAt: #bcctr
]

{ #category : #processors }
AcMnemonicTest >> forPowerPC [
	^AcSetAsmParser pdl: AcProcessorDescriptions powerpc
]

{ #category : #processors }
AcMnemonicTest >> forSPARC [
	^AcSetAsmParser pdl: AcProcessorDescriptions sparcv8
]

{ #category : #'tests - instructions - PowerPC' }
AcMnemonicTest >> mfspr [
	^AcProcessorDescriptions powerpc instructionAt: #mfspr
]

{ #category : #'tests - instructions - ARM' }
AcMnemonicTest >> testArmAND1 [
	| groundedInstr s |
	groundedInstr := self and1 inEnvironment: (Dictionary new
		at: 'cond' put: 12;
		at: 's' put: 1;
		at: 'rd' put: 0;
		at: 'rn' put: 0;
		at: 'rm' put: 13;
		at: 'shiftamount' put: 0;
		at: 'shift' put: 0;
		yourself).
	s := groundedInstr disassemble.
	self assert:  s equals: 'andgts a1, a1, sp'
]

{ #category : #'tests - instructions - ARM' }
AcMnemonicTest >> testArmAdd3 [
	| groundedInstr s |
	true ifTrue: [ ^self flag: #TODO ].
	groundedInstr := self add3 inEnvironment: (Dictionary new
		at: 'cond' put: 12;
		at: 's' put: 1;
		at: 'rd' put: 2;
		at: 'rn' put: 3;
		at: 'rotate' put: 3;
		at: 'imm8' put: 4;
		yourself).
	s := groundedInstr disassemble.
	self assert:  s = 'addgts a3, a4, #0x7(aimm)'
]

{ #category : #'tests - instructions - ARM' }
AcMnemonicTest >> testArmAddPC [
	| groundedInstr s |
	groundedInstr := self add1 inEnvironment: (Dictionary new
		at: 'cond' put: 12;
		at: 's' put: 1;
		at: 'rd' put: 0;
		at: 'rn' put: 15;
		at: 'rm' put: 13;
		at: 'shiftamount' put: 0;
		at: 'shift' put: 0;
		yourself).
	s := groundedInstr disassemble.
	self assert:  s = 'addgts a1, PC, sp'
]

{ #category : #'tests - simple' }
AcMnemonicTest >> testBasic [
	| mnem spec result |
	mnem := '"Literal string"'.
	spec := self forPowerPC parse: mnem.
	result := spec disassembleEnv: Dictionary new.
	self assert: result = ('Literal string' -> 0)
]

{ #category : #'tests - simple' }
AcMnemonicTest >> testOneBinding [
	| mnem spec env s numBoundOperands |
	mnem := '"mov %reg, %reg", rt, rd, c=3'.
	spec := self forPowerPC parse: mnem.
	env := Dictionary new 
		at: 'rt' put: 5;
		at: 'rd' put: 7;
		at: 'c' put: 3;
		yourself.
	s := spec disassembleEnv: env.
	numBoundOperands := s value.
	self assert: s key = 'mov 5, 7'.
	self assert: numBoundOperands = 1
]

{ #category : #'tests - simple' }
AcMnemonicTest >> testOneNegate [
	| mnem spec env s  |
	mnem := '"R %reg", r=10'.
	spec := self forPowerPC parse: mnem.
	env := Dictionary new 
		at: 'r' put: 5;
		yourself.
	s := spec disassembleEnv: env.
	self assert: s isNil
]

{ #category : #'tests - simple' }
AcMnemonicTest >> testOneReg [
	| mnem spec env s  |
	mnem := '"R %reg", r'.
	spec := self forPowerPC parse: mnem.
	env := Dictionary new 
		at: 'r' put: 5;
		yourself.
	s := spec disassembleEnv: env.
	self assert: s key = 'R 5'
]

{ #category : #'tests - instructions - PowerPC' }
AcMnemonicTest >> testPowerPcADDI [
	| groundedInstr |
	groundedInstr := self addi inEnvironment: (Dictionary new
		at: 'rt' put: 3;
		at: 'ra' put: 0; "the idea is that when ra==0, addi mnemonic specializes to li"
		at: 'd' put: 16r1234;
		yourself).
	self assert: (groundedInstr disassemble beginsWith: 'li ')
]

{ #category : #'tests - instructions - PowerPC' }
AcMnemonicTest >> testPowerPcBCTR [
	| groundedInstr  |
	groundedInstr := self bcctr inEnvironment: (Dictionary new
		at: 'bo' put: 16r14;
		at: 'bi' put: 0;
		at: 'bh' put: 0;
		yourself).
	self assert: groundedInstr disassemble equals: 'bctr'
]

{ #category : #'tests - instructions - PowerPC' }
AcMnemonicTest >> testPowerPcGeneralBCCTR [
	| groundedInstr  |
	groundedInstr := self bcctr inEnvironment: (Dictionary new
		at: 'bo' put: 1;
		at: 'bi' put: 2;
		at: 'bh' put: 3;
		yourself).
	self assert: groundedInstr disassemble equals: 'bcctr 1, 2, 3'
]

{ #category : #'tests - instructions - PowerPC' }
AcMnemonicTest >> testPowerPcGeneralMFSPR [
	| groundedInstr s |
	groundedInstr := self mfspr inEnvironment: (Dictionary new
		at: 'rt' put: 3;
		at: 'sprf' put: 16r23;
		yourself).
	s := groundedInstr disassemble.
	self assert: s = 'mfspr 0x3, 0x23'
]

{ #category : #'tests - instructions - PowerPC' }
AcMnemonicTest >> testPowerPcMFCTR [
	| grounded |
	grounded := self mfspr inEnvironment: (Dictionary new
		at: 'rt' put: 1;
		at: 'sprf' put: 16r120;
		yourself).
	self assert: grounded disassemble equals: 'mfctr 0x1'
]
