Class {
	#name : #AcMnemonicFormatTest,
	#superclass : #TestCaseWithZ3Context,
	#category : #'ArchC-Tests'
}

{ #category : #powerpc }
AcMnemonicFormatTest >> forPowerPC [
	^AcSetAsmParser pdl: AcProcessorDescriptions powerpc
]

{ #category : #sparc }
AcMnemonicFormatTest >> forSPARC [
	^AcSetAsmParser pdl: AcProcessorDescriptions sparcv8
]

{ #category : #powerpc }
AcMnemonicFormatTest >> proc: parser spec: aSetAsmString operandKeys: k operandValues: v expect: e [
	| env parseResult s |
	parseResult := parser parse: aSetAsmString.
	env := Dictionary newFromKeys: k andValues: v.
	s := parseResult disassembleEnv: env.
	self assert: s key equals: e
]

{ #category : #arm }
AcMnemonicFormatTest >> testADD3 [
	| parseResult fmt |
	fmt := 'adr%[cond]%sf %reg, %exp(pcrelrot)'.
	parseResult := (AcMnemonicFormatParser maps: AcProcessorDescriptions armv5 maps) parse: fmt.
	self deny: parseResult isPetitFailure 
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testBasic [
	| env parseResult |
	parseResult := self forPowerPC parse: '"Simple"'.
	env := Dictionary new.
	self assert: (parseResult disassembleEnv: env) key equals: 'Simple'
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testBasicFormat [
	| formatParser parseResult firstChunk stream |
	formatParser := 	AcMnemonicFormatParser maps: AcProcessorDescriptions powerpc maps.
	parseResult := formatParser parse: 'Simple string'.
	firstChunk := parseResult first.
	stream := WriteStream on: String new.
	firstChunk disassembleTo: stream  inEnvironment: OrderedCollection new.
	self assert: stream contents equals: 'S'
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testEscapePercent [
	| env parseResult fmt |
	fmt := '"a\%b"'.
	parseResult := self forPowerPC parse: fmt.
	env := Dictionary new.
	self assert: (parseResult disassembleEnv: env) key equals: 'a%b'
]

{ #category : #sparc }
AcMnemonicFormatTest >> testManySPARC [
	self
		proc: self forSPARC 
		spec: '"Register %reg, %reg, %cond", r, s, c'
		operandKeys: #('r' 's' 'c')
		operandValues: #(27 9 5)
		expect: 'Register %i3, %o1, ne'
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testOneImm [
	self
		proc: self forPowerPC 
		spec: '"One #%imm imm", x'
		operandKeys: #('x')
		operandValues: #(5)
		expect: 'One #0x5 imm'.
	
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testOneRegPPC [
	self
		proc: self forPowerPC 
		spec: '"Register %reg", RRR'
		operandKeys: #('RRR')
		operandValues: #(2)
		expect: 'Register 2'.
]

{ #category : #sparc }
AcMnemonicFormatTest >> testOneRegSPARC [
	self
		proc: self forSPARC 
		spec: '"Register %reg", r'
		operandKeys: #('r')
		operandValues: #(27)
		expect: 'Register %i3'
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testWeirdCharsPPC [
	self
		proc: self forPowerPC 
		spec: '"la %reg, %exp@l(%imm)", x, y, z'
		operandKeys: #('x' 'y' 'z')
		operandValues: #(2 0 16r555)
		expect: 'la 2, 0x0@l(0x555)'.
]
