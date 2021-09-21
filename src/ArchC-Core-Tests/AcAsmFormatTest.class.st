Class {
	#name : #AcAsmFormatTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #mips }
AcAsmFormatTest >> forMIPS [
	^AcSetAsmParser pdl: AcProcessorDescriptions mips 
]

{ #category : #powerpc }
AcAsmFormatTest >> forPowerPC [
	^AcSetAsmParser pdl: AcProcessorDescriptions powerpc
]

{ #category : #sparc }
AcAsmFormatTest >> forSPARC [
	^AcSetAsmParser pdl: AcProcessorDescriptions sparcv8
]

{ #category : #generic }
AcAsmFormatTest >> proc: parser spec: aSetAsmString operandKeys: k operandValues: v format: f expect: e [
	| env parseResult s |
	parseResult := parser parse: aSetAsmString. "a SetAsm"
	f isNil ifFalse: [
		parseResult instruction: (MockFormatPoznavach format: f pdl: parser pdl)
	].
	env := Dictionary newFromKeys: k andValues: v.
	s := parseResult disassembleEnv: env.
	self assert: s key equals: e
]

{ #category : #arm }
AcAsmFormatTest >> testADD3 [
	| parseResult  fmt |

	fmt := 'adr%[cond]%sf %reg, %exp(pcrelrot)'.
	parseResult := (AcAsmFormatParser maps: AcProcessorDescriptions armv5 maps) 
			parse: fmt.
	 "parseResult is a sequence of chunks"
	self deny: parseResult isPetitFailure
]

{ #category : #powerpc }
AcAsmFormatTest >> testBasic [
	| parseResult ass |
	parseResult := self forPowerPC parse: '"Simple"'.
	"parserResult is an AcSetAsm"
	
	ass := parseResult disassembleEnv: Dictionary new.
	"disassembly->weight"
	self assert: ass key equals: 'Simple'.
	self assert: ass value equals: 0
]

{ #category : #generic }
AcAsmFormatTest >> testBasicFormat [
	| formatParser  parseResult  firstChunk  stream |

	formatParser := AcAsmFormatParser 
			maps: AcProcessorDescriptions powerpc maps.
	parseResult := formatParser parse: 'Simple string'.
	firstChunk := parseResult first.
	stream := WriteStream on: String new.
	firstChunk 
		disassembleTo: stream
		operands: #()
		inEnvironment: OrderedCollection new.
	self assert: stream contents equals: 'S'
]

{ #category : #powerpc }
AcAsmFormatTest >> testEscapePercent [
	| env parseResult fmt x |
	fmt := '"a\%b"'.
	parseResult := self forPowerPC parse: fmt.
	env := Dictionary new.
	x := parseResult disassembleEnv: env.
	self assert: x key equals: 'a%b'.
	self assert: x value equals: 0
]

{ #category : #sparc }
AcAsmFormatTest >> testOneCondSPARC [
	self
		proc: self forSPARC 
		spec: '"Condition %cond", cond'
		operandKeys: #('cond')
		operandValues: #(14)
		format: 'Type_F2B'
		expect: 'Condition pos'
]

{ #category : #mips }
AcAsmFormatTest >> testOneImm [
	self
		proc: self forMIPS
		spec: '"One #%imm imm", addr'
		operandKeys: #('addr')
		operandValues: #(5)
		format: 'Type_J'
		expect: 'One #0x5 imm'.
	
]

{ #category : #powerpc }
AcAsmFormatTest >> testOneRegPPC [
	self
		proc: self forPowerPC 
		spec: '"Register %reg", RRR'
		operandKeys: #('RRR')
		operandValues: #(2)
		format: nil
		expect: 'Register 2'.
]

{ #category : #powerpc }
AcAsmFormatTest >> testWeirdCharsPPC [
	self
		proc: self forPowerPC 
		spec: '"la %reg, %exp@l(%imm)", rt, d, ra'
		operandKeys: #('rt' 'ra' 'd')
		operandValues: #(2 0 16r555)
		format: 'D1'
		expect: 'la 2, 0x555@l(0x0)' "Fun: ra here is %imm, not %reg"
]
