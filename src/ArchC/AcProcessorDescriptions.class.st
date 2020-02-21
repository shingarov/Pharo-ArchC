"
I know where to find some example PDL descriptions.
"
Class {
	#name : #AcProcessorDescriptions,
	#superclass : #Object,
	#category : #'ArchC-Tests'
}

{ #category : #'known processors' }
AcProcessorDescriptions class >> armv5 [
	"  AcProcessorDescriptions armv5  "
	^AcArchParser
		processor: 'arm'
		in: self baseDirectory, 'arm'
]

{ #category : #'working directory' }
AcProcessorDescriptions class >> baseDirectory [
	(VirtualMachine new buildDate beginsWith: 'Mac')
		ifTrue: [^'/Users/boris/PDL/'].
	(VirtualMachine new buildDate beginsWith: 'Unix')
		ifTrue: [^'/home/boris/PDL/'].
	self error: 'Where am I???'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> knownProcessors [
	^OrderedCollection 
		with: self powerpc 
		with: self armv5 
		with: self mips
		with: self sparcv8
		with: self r3000
		with: self riscv
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> mips [
	^AcArchParser
		processor: 'mips'
		in: self baseDirectory, 'mips'

]

{ #category : #'known processors' }
AcProcessorDescriptions class >> powerpc [
	"  AcProcessorDescriptions powerpc  "
	^AcArchParser
		processor: 'powerpc'
		in: self baseDirectory, 'powerpc'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> r3000 [
	^AcArchParser
		processor: 'r3000'
		in: self baseDirectory, 'r3000'

]

{ #category : #'known processors' }
AcProcessorDescriptions class >> riscv [
	"  AcProcessorDescriptions riscv  "
	^AcArchParser
		processor: 'riscv'
		in: self baseDirectory, 'riscv'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> sparcv8 [
	"  AcProcessorDescriptions sparcv8  "
	^AcArchParser
		processor: 'sparc'
		in: self baseDirectory, 'sparc'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> x86 [
	"  AcProcessorDescriptions x86  "
	^AcArchParser
		processor: 'IA32'
		in: self baseDirectory, 'x86'
]
