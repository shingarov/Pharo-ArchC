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
	instr := AcProcessorDescriptions armv5  decodeInt: (16rE59FC034 toBitVector: 32).
	self assert: (instr fieldValue: 'u') equals: 1.
	self assert: (
	#(   'ldr ip, [pc, #+0x34]'
		 'ldr ip, [pc, #0x34]'
		 'ldr ip, 52'   )
		includes:  instr disassemble)
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
TextDisassemblyTest >> testPowerSc [
	| instr text |
	instr := AcProcessorDescriptions powerpc decode: 16r44000002 .
	text := instr disassemble.
	self assert: text equals: 'sc'.

]

{ #category : #tests }
TextDisassemblyTest >> testRiscvJAL [
	| instr text |
	instr := AcProcessorDescriptions riscv decode: 16r008500e7 . "jalr ra, a0, 8"
	text := instr disassemble.
	self assert: text equals: 'jalr ra, a0, 0x8'.

]
