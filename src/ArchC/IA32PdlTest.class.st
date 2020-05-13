Class {
	#name : #IA32PdlTest,
	#superclass : #TestCaseWithZ3Context,
	#category : #'ArchC-Tests'
}

{ #category : #definitions }
IA32PdlTest >> pdl [
	^AcProcessorDescriptions x86

]

{ #category : #tests }
IA32PdlTest >> testLoadPDL [
	" The most basic test --
	  just load the PDL and ensure basic sanity.
	  If this fails, everything else probably will, too. "
	| dr drIB |
	dr := self pdl instructionAt: #dump_registers.
	drIB := dr internalBindings.
	self assert: (drIB at: 'op2b') equals: 16rDD00.
]

{ #category : #tests }
IA32PdlTest >> testNOP [
	| nop binary |
	nop := AcProcessorDescriptions x86 instructionAt: #nop.
	binary := nop binaryEncoding. "0x90"
	self assert: binary equals: (2r10010000 asBitVector: 8)
]
