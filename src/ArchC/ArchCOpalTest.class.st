Class {
	#name : #ArchCOpalTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests-Opal'
}

{ #category : #compiler }
ArchCOpalTest class >> compiler [
	^ super compiler addPlugin: PDLOpalPlugin 
]

{ #category : #arm }
ArchCOpalTest >> and1 [
	<armv5: 'andgts a1, a1, sp'>
]

{ #category : #powerpc }
ArchCOpalTest >> lbzu: x [
	<powerpc: 'lbzu 1, {x} (2)'>
]

{ #category : #powerpc }
ArchCOpalTest >> loadImm32: x [
	<powerpc: 'lis 3, {x>>16}'>
	<powerpc: 'ori 3, 3, {x bitAnd: 16rFFFF}'>
]

{ #category : #x86 }
ArchCOpalTest >> nop [
	<x86: 'NOP'>
]

{ #category : #tests }
ArchCOpalTest >> template [
	| instr theEnvironment |
	"theEnvironment := Dictionary
		newFromKeys: (thisContext method argumentNames collect: #asString)
		andValues: thisContext arguments."
	theEnvironment := Dictionary new .
	1. 2. 3. 4.
	instr := #theInstruction.
	^instr inEnvironment: theEnvironment
]

{ #category : #tests }
ArchCOpalTest >> testLBZU [
	| x |
	x := self lbzu: 8.
	self assert: (x value bitAnd: 16rFFFF) equals: 8
]

{ #category : #tests }
ArchCOpalTest >> testLoadImm32 [
	| x |
	x := self loadImm32: 16r12345678.
	self assert: (x value bitAnd: 16rFFFF) equals: 16r5678
	
]

{ #category : #tests }
ArchCOpalTest >> testNOP [
	| x |
	x := self nop.
	self assert: x length equals: 8.
	self assert: x value equals: 16r90.

]
