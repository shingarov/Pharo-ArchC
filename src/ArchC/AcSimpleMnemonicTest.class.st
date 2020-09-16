Class {
	#name : #AcSimpleMnemonicTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests'
}

{ #category : #tests }
AcSimpleMnemonicTest >> forPowerPC [
	^AcSetAsmParser pdl: AcProcessorDescriptions powerpc
]

{ #category : #tests }
AcSimpleMnemonicTest >> testAssembleImm [
	| mnem parser spec result |
	mnem := '"abc %imm", d'.
	parser := self forPowerPC.
	spec := parser parse: mnem.
	spec instruction: (MockFormatPoznavach format: 'D3' pdl: parser pdl).
	result := spec assembler parse: 'abc 1234'.
	self assert: (result at: 'd') equals: 1234
]

{ #category : #tests }
AcSimpleMnemonicTest >> testDisassembleImm [
	| mnem parser spec result |
	mnem := '"abc %imm", d'.
	parser := self forPowerPC.
	spec := parser parse: mnem.
	spec instruction: (MockFormatPoznavach format: 'D3' pdl: parser pdl).
	result := spec disassembleEnv: (Dictionary new
		at: 'd' put: 16r123;
		yourself).
	self assert: result = ('abc 0x123' -> 0)
]

{ #category : #tests }
AcSimpleMnemonicTest >> testTrivialDisassembly [
	| mnem spec result |
	mnem := '"Literal string"'.
	spec := self forPowerPC parse: mnem.
	result := spec disassembleEnv: Dictionary new.
	self assert: result = ('Literal string' -> 0)
]
