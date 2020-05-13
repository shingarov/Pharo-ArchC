Class {
	#name : #JustParsePDLTest,
	#superclass : #TestCaseWithZ3Context,
	#category : #'ArchC-Tests-Parsing'
}

{ #category : #tests }
JustParsePDLTest >> testParsePPC [
	self assert: AcProcessorDescriptions powerpc architectureName equals: 'powerpc'
]
