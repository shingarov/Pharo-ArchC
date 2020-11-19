Class {
	#name : #ArchCOpalTest,
	#superclass : #TestCase,
	#category : #'ArchC-Extras-Pharo-Tests'
}

{ #category : #compiler }
ArchCOpalTest class >> compiler [
	^ super compiler addPlugin: PDLOpalPlugin 
]

{ #category : #initialization }
ArchCOpalTest class >> finishLoading [
	"
	ArchCOpalTest finishLoading
	"
	self initZ3Context.
	ClyPDLEnvironmentPlugin toActivateMe.
]

{ #category : #initialization }
ArchCOpalTest class >> initZ3Context [
	"
	ArchCOpalTest initZ3Context
	"
	Z3Context createGlobalContext.
	self recompile 
]

{ #category : #compiler }
ArchCOpalTest class >> template [ 
	^ArchCOpalTest >> #templateMethod 
]

{ #category : #assembler }
ArchCOpalTest >> and1 [
	<armv5: 'andgts a1, a1, sp'> 
]

{ #category : #assembler }
ArchCOpalTest >> ba: adr [
	<powerpc: 'ba {adr}'>
]

{ #category : #tests }
ArchCOpalTest >> bytesFrom: collectionOfBVs [
	| byteStream |
	byteStream := WriteStream on: (ByteArray new: 32).
	self spitBytesOf: collectionOfBVs on: byteStream.
	^byteStream contents
]

{ #category : #assembler }
ArchCOpalTest >> lbzu: x [
	<powerpc: 'lbzu 1, {x} (2)'> 
]

{ #category : #assembler }
ArchCOpalTest >> ldr1: offset [
	<armv5: 'ldr ip, {offset}'>
]

{ #category : #assembler }
ArchCOpalTest >> ldrIpPCREL: offset [
	<armv5: 'ldr ip, {offset}'>

]

{ #category : #assembler }
ArchCOpalTest >> loadImm32: x [
	<powerpc: 'lis 3, {x>>16}'>
	<powerpc: 'ori 3, 3, {x bitAnd: 16rFFFF}'>
]

{ #category : #assembler }
ArchCOpalTest >> lugLBZU: x [
	"<powerpc: 'lbzu 1, {(x asBitVector: 16)+y} (2)'>" 
]

{ #category : #assembler }
ArchCOpalTest >> mov3synth [
	<armv5: 'mov r3, #4080'>
]

{ #category : #assembler }
ArchCOpalTest >> mov3synth: x [
	<armv5: 'mov r3, #{x}'>
]

{ #category : #'z3 context' }
ArchCOpalTest >> setUp [
"	Z3Context createGlobalContext.
	AcProcessorDescriptions reset.
	self class recompile
	"
]

{ #category : #tests }
ArchCOpalTest >> spit: bvs [
self shouldBeImplemented 
]

{ #category : #tests }
ArchCOpalTest >> spitBytesOf: collectionOfBVs on: aByteStream [
	collectionOfBVs do: [ :bv |
		aByteStream nextPutAll: bv asBEByteArray ]
]

{ #category : #assembler }
ArchCOpalTest >> str1 [
	<armv5: 'str sl, [sp, #-4]!'>
]

{ #category : #assembler }
ArchCOpalTest >> str1: srcR [
	<armv5: 'str {srcR}, [sp, #-0x4]!'> 
]

{ #category : #'z3 context' }
ArchCOpalTest >> tearDown [
	"Z3Context current del"
]

{ #category : #tests }
ArchCOpalTest >> templateMethod [
	| instr theEnvironment |
	theEnvironment := Dictionary new .
	1. 2. 3. 4. 5. 6. 7. 8.
	instr := #theInstruction.
	^instr inEnvironment: theEnvironment
]

{ #category : #tests }
ArchCOpalTest >> testBA [
	| emitted parsedInstr |
	emitted := (self ba: 20) first. "jump to absolute 20"
	parsedInstr := AcProcessorDescriptions powerpc decode: emitted.
	"BOGUS BEHAVIOR OF THE ARCHC ASSEMBLER.
	ArchC does not indicate to us that the meaning of the li operand
	is taken as shifted by two bits."
	self assert: (parsedInstr fieldValue: 'li') equals: 20
]

{ #category : #tests }
ArchCOpalTest >> testLBZU [
	| x |
	x := self lbzu: 8.
	self assert: (x value bitAnd: 16rFFFF) equals: 8 
]

{ #category : #tests }
ArchCOpalTest >> testLdrPCRELNegative [
	| x instr |
	x := self ldrIpPCREL: -12.
	instr := AcProcessorDescriptions armv5 decode: x first.
	self assert: (instr fieldValue: 'u') equals: 0
]

{ #category : #tests }
ArchCOpalTest >> testLdrPCRELPositive [
	| x instr |
	x := self ldrIpPCREL: 12.
	instr := AcProcessorDescriptions armv5 decode: x first.
	self assert: (instr fieldValue: 'u') equals: 1
]

{ #category : #tests }
ArchCOpalTest >> testLoadImm32 [
	| x first second |
	x := self loadImm32: 16r12345678.
	first := x first.
	second := x second.
	self assert: (first  value bitAnd: 16rFFFF) equals: 16r1234.
	self assert: (second value bitAnd: 16rFFFF) equals: 16r5678.
	
]

{ #category : #tests }
ArchCOpalTest >> testLugLBZU [
	"| instr y |
	instr := self lugLBZU: 8.
	y := 1.
	instr := instr inThisEnvironment.
	self assert: (instr value bitAnd: 16rFFFF) equals: 8+1"
]

{ #category : #tests }
ArchCOpalTest >> testMov3synth [
	| x |
	x := self mov3synth.
	self assert: x first value equals: 16rE3A03EFF
	
]

{ #category : #tests }
ArchCOpalTest >> testMov3synth_ [
	| x first second |
	x := self mov3synth: 16rFF0.
	
	self assert: (first  value bitAnd: 16rFFFF) equals: 16r1234.
	self assert: (second value bitAnd: 16rFFFF) equals: 16r5678.
	
]
