"
I know where to find some example PDL descriptions.
"
Class {
	#name : #AcProcessorDescriptions,
	#superclass : #Object,
	#classInstVars : [
		'cache'
	],
	#category : #'ArchC-Tests'
}

{ #category : #'known processors' }
AcProcessorDescriptions class >> armv5 [
	"  AcProcessorDescriptions armv5  "
	^self processor: 'arm' in: 'arm'
]

{ #category : #'working directory' }
AcProcessorDescriptions class >> baseDirectory [
	(VirtualMachine new buildDate beginsWith: 'Mac')
		ifTrue: [^'/Users/boris/PDL/'].
	(VirtualMachine new buildDate beginsWith: 'Unix')
		ifTrue: [^'/home/boris/PDL/'].
	self error: 'Where am I???'
]

{ #category : #cache }
AcProcessorDescriptions class >> cachedProcessors [
	cache isNil ifTrue: [ cache := Dictionary new ].
	^cache
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> mips [
	^self processor: 'mips' in: 'mips'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> powerpc [
	"  AcProcessorDescriptions powerpc  "
	^self processor: 'powerpc' in: 'powerpc'
]

{ #category : #cache }
AcProcessorDescriptions class >> processor: isaName in: dir [
	^self cachedProcessors at: isaName ifAbsentPut: [
		AcArchParser
			processor: isaName
			in: self baseDirectory, dir ]
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> r3000 [
	"  AcProcessorDescriptions r3000  "
	^self processor: 'r3000' in: 'r3000'
]

{ #category : #cache }
AcProcessorDescriptions class >> reset [ 
	cache := nil
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> riscv [
	"  AcProcessorDescriptions riscv  "
	^self processor: 'riscv' in: 'riscv'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> sparcv8 [
	"  AcProcessorDescriptions sparcv8  "
	^self processor: 'sparc' in: 'sparc'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> x86 [
	"  AcProcessorDescriptions x86  "
	^self processor: 'IA32' in: 'x86'
]
