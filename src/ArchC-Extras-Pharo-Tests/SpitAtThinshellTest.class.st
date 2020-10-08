Class {
	#name : #SpitAtThinshellTest,
	#superclass : #TestCase,
	#instVars : [
		'gdb',
		'dot',
		'memory'
	],
	#category : #'ArchC-Extras-Pharo-Tests'
}

{ #category : #compiler }
SpitAtThinshellTest class >> compiler [
	^ super compiler addPlugin: PDLOpalPlugin 
]

{ #category : #compiler }
SpitAtThinshellTest class >> template [
	^SpitAtThinshellTest >> #templateMethod
]

{ #category : #tests }
SpitAtThinshellTest >> connectGdb [
	gdb := RemoteGDBSession 
		host: '192.168.75.2'
		port: 7000
		processorDescription: AcProcessorDescriptions powerpc 
	
]

{ #category : #tests }
SpitAtThinshellTest >> createRAM [
	memory := Gem5SharedRAM gdb: gdb.
	memory shmemSize: 20*1024*1024.
]

{ #category : #tests }
SpitAtThinshellTest >> loadImm32: x [
	<powerpc: 'lis 3, {x>>16}'>
	<powerpc: 'ori 3, 3, {x bitAnd: 16rFFFF}'> 
]

{ #category : #tests }
SpitAtThinshellTest >> setUp [
	"
	Z3Context createGlobalContext.
	AcProcessorDescriptions reset.
	self class recompile
	"
	
]

{ #category : #tests }
SpitAtThinshellTest >> spitAll: bvs [
	bvs do: [ :bv | self spitOne: bv ]
]

{ #category : #'as yet unclassified' }
SpitAtThinshellTest >> spitOne: bv [
self shouldBeImplemented .
	#memory longAtAddr: dot put: bv value bigEndian: true.
	#dot + 4
]

{ #category : #tests }
SpitAtThinshellTest >> templateMethod [
	| instr theEnvironment |
	theEnvironment := Dictionary new .
	1. 2. 3. 4. 5. 6. 7. 8.
	instr := #theInstruction.
	^self spitAll: (instr inEnvironment: theEnvironment)
]

{ #category : #tests }
SpitAtThinshellTest >> testEmitAndRun [
	self connectGdb; createRAM.
	dot := 16r20000.
	self loadImm32: 16r12345678.
	gdb s; s.
	self assert: (gdb getRegister: 'r3') equals: 16r12345678.
	
]
