Class {
	#name : #AcMnemonicFormatTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests-Parsing'
}

{ #category : #powerpc }
AcMnemonicFormatTest >> forPowerPC [
	^AcMnemonicFormatParser maps: AcProcessorDescriptions powerpc maps
]

{ #category : #sparc }
AcMnemonicFormatTest >> forSPARC [
	^AcMnemonicFormatParser maps: AcProcessorDescriptions sparcv8 maps
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testBasic [
	| env parseResult fmt |
	fmt := 'Simple string'.
	parseResult := self forPowerPC parse: fmt.
	env := OrderedCollection new.
	self assert: (parseResult value: env) = fmt
]

{ #category : #sparc }
AcMnemonicFormatTest >> testManySPARC [
	| env parseResult s |
	parseResult := self forSPARC parse: 'Register %reg, %reg, %cond'.
	env := OrderedCollection with: 27 with: 9 with: 5.
	s := parseResult value: env.
	self assert: s = 'Register %i3, %o1, ne'
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testOneImm [
	| env parseResult s |
	parseResult := self forPowerPC parse: 'One #%imm imm'.
	env := OrderedCollection with: 5.
	s := parseResult value: env.
	self assert: s = 'One #0x5 imm'
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testOneRegPPC [
	| env parseResult s |
	parseResult := self forPowerPC parse: 'Register %reg'.
	env := OrderedCollection with: 2.
	s := parseResult value: env.
	self assert: s = 'Register 2'
]

{ #category : #sparc }
AcMnemonicFormatTest >> testOneRegSPARC [
	| env parseResult s |
	parseResult := self forSPARC parse: 'Register %reg'.
	env := OrderedCollection with: 27.
	s := parseResult value: env.
	self assert: s = 'Register %i3'
]

{ #category : #powerpc }
AcMnemonicFormatTest >> testWeirdCharsPPC [
	| env parseResult s |
	parseResult := self forPowerPC parse: 'la %reg, %exp@l(%imm)'.
	env := OrderedCollection with: 2 with: 0 with: 16r555.
	s := parseResult value: env.
	self assert: s = 'la 2, 0x0@l(0x555)'
]
