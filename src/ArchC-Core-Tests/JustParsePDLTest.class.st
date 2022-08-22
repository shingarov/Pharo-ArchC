Class {
	#name : #JustParsePDLTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #accessing }
JustParsePDLTest class >> resources [
	^ Array with: AcProcessorDescriptionsResource

]

{ #category : #tests }
JustParsePDLTest >> testParseARM [
	self assert: AcProcessorDescriptions armv5 architectureName equals: 'arm'
]

{ #category : #tests }
JustParsePDLTest >> testParseMIPS [
	self assert: AcProcessorDescriptions mips architectureName equals: 'mips'
]

{ #category : #tests }
JustParsePDLTest >> testParsePPC [
	self assert: AcProcessorDescriptions powerpc architectureName equals: 'powerpc'
]

{ #category : #tests }
JustParsePDLTest >> testParseSPARC [
	self assert: AcProcessorDescriptions sparcv8 architectureName equals: 'sparc'
]
