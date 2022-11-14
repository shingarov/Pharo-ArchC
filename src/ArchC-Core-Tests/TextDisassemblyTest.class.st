Class {
	#name : #TextDisassemblyTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #accessing }
TextDisassemblyTest class >> resources [
	^ Array with: AcProcessorDescriptionsResource

]

{ #category : #'tests - arm' }
TextDisassemblyTest >> testArmLdrPCREL [
	| instr |
	instr := AcProcessorDescriptions armv5 decodeBits: (16rE59FC034 toBitVector: 32).
	self assert: (instr fieldValue: 'u') equals: 1.
	self assert: (
	#(   'ldr ip, [pc, #+0x34]'
		 'ldr ip, [pc, #0x34]'
		 'ldr ip, 52'   )
		includes:  instr disassemble)
]

{ #category : #'tests - powerpc' }
TextDisassemblyTest >> testEndianPalindrome [
	| pdl |
	pdl := AcProcessorDescriptions powerpc64.
	self assert: (pdl disassemble: 16r08000048) equals: 'tdi 0x0, 0, 0x48'.
	self assert: (pdl disassemble: 16r48000008) equals: 'b .+0x8'.
]

{ #category : #'tests - powerpc' }
TextDisassemblyTest >> testPowerAdd [
	| instr text |
	instr := AcProcessorDescriptions powerpc decode: 16r62830001 .
	text := instr disassemble.
	self assert: text equals: 'ori 3, 20, 0x1'.

]

{ #category : #'tests - powerpc' }
TextDisassemblyTest >> testPowerOriSymbolic [
	| instr text binary |
	binary := (16r6283 toBitVector: 16), ('x' toBitVector: 16).
	instr := AcProcessorDescriptions powerpc decode: binary.
	text := instr disassemble.
	self assert: text equals: 'ori 3, 20, {x}'.

]

{ #category : #'tests - powerpc' }
TextDisassemblyTest >> testPowerOriSymbolic2 [
	| encoding disasm |

	encoding := (2r01100010100 toBitVector: 11) , ('dstReg' toBitVector: 5) , (16r0001 toBitVector: 16).
	disasm := AcProcessorDescriptions powerpc disassemble: encoding.
	self assert: disasm equals: 'ori {dstReg}, 20, 0x1'
]

{ #category : #'tests - powerpc' }
TextDisassemblyTest >> testPowerSc [
	| instr text |
	instr := AcProcessorDescriptions powerpc decode: 16r44000002 .
	text := instr disassemble.
	self assert: text equals: 'sc'.

]
