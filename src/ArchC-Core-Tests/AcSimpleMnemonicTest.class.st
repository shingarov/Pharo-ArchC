Class {
	#name : #AcSimpleMnemonicTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #accessing }
AcSimpleMnemonicTest class >> resources [
	^ Array with: AcProcessorDescriptionsResource

]

{ #category : #tests }
AcSimpleMnemonicTest >> forPowerPC [
	^AcSetAsmParser pdl: AcProcessorDescriptions powerpc
]

{ #category : #tests }
AcSimpleMnemonicTest >> testAssembleExp [
	| mnem parser spec result |
	mnem := '"abc %exp", d'.
	parser := self forPowerPC.
	spec := parser parse: mnem.
	spec instruction: (MockFormatPoznavach format: 'D3' pdl: parser pdl).
	result := spec assembler parse: 'abc 1234'.
	self assert: (result at: 'd') equals: 1234
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
AcSimpleMnemonicTest >> testAssembleImmHex [
	| mnem parser spec result |
	mnem := '"abc %imm", d'.
	parser := self forPowerPC.
	spec := parser parse: mnem.
	spec instruction: (MockFormatPoznavach format: 'D3' pdl: parser pdl).
	result := spec assembler parse: 'abc 0x1234'.
	self assert: (result at: 'd') equals: 16r1234
]

{ #category : #tests }
AcSimpleMnemonicTest >> testAssembleMinusExp [
	| mnem parser spec result |
	mnem := '"abc %exp", d'.
	parser := self forPowerPC.
	spec := parser parse: mnem.
	spec instruction: (MockFormatPoznavach format: 'D3' pdl: parser pdl).
	result := spec assembler parse: 'abc -5'.
	self assert: (result at: 'd') equals: -5
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
	self assert: result = 'abc 0x123'
]

{ #category : #tests }
AcSimpleMnemonicTest >> testImmIsSignless [
	| mnem parser spec result |
	mnem := '"abc %imm", d'.
	parser := self forPowerPC.
	spec := parser parse: mnem.
	spec instruction: (MockFormatPoznavach format: 'D3' pdl: parser pdl).
	result := spec assembler parse: 'abc -5'.
	self assert: (result isKindOf: PPFailure).

]

{ #category : #tests }
AcSimpleMnemonicTest >> testSymbolicExp [
	| mnem parser spec result |
	mnem := '"abc %exp", d'.
	parser := self forPowerPC.
	spec := parser parse: mnem.
	spec instruction: (MockFormatPoznavach format: 'D3' pdl: parser pdl).
	result := spec assembler parse: 'abc {x+y}'.
	self assert: (result at: 'd') equals: 'x+y'
]

{ #category : #tests }
AcSimpleMnemonicTest >> testTrivialDisassembly [
	| mnem spec result |
	mnem := '"Literal string"'.
	spec := self forPowerPC parse: mnem.
	result := spec disassembleEnv: Dictionary new.
	self assert: result = 'Literal string'
]
