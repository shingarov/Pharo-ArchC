Class {
	#name : #ComputedAsmMapTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests-Opal'
}

{ #category : #compiler }
ComputedAsmMapTest class >> compiler [
	^ super compiler addPlugin: PDLOpalPlugin 
]

{ #category : #instructions }
ComputedAsmMapTest >> and1: x [
	<armv5: 'andgts a1, a1, {x}'>
]

{ #category : #running }
ComputedAsmMapTest >> setUp [
	Z3Context createGlobalContext.
	self class recompile
]

{ #category : #tests }
ComputedAsmMapTest >> test1 [ 
	| encoding |
	encoding := self and1: 15. "r15 is pc"
	self assert: (AcProcessorDescriptions armv5 disassemble: encoding) disassemble equals: 'andgts a1, a1, pc'
]
