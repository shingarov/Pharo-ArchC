Class {
	#name : #AcSymbolicDecodeTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #accessing }
AcSymbolicDecodeTest class >> resources [
	^ Array with: AcProcessorDescriptionsResource

]

{ #category : #'test objects' }
AcSymbolicDecodeTest >> lbz [
	^AcProcessorDescriptions powerpc instructionAt: #lbz
]

{ #category : #'tests - concrete instructions' }
AcSymbolicDecodeTest >> test88221234AlwaysFitsConcreteLBZ [
	| aConcreteLBZ |
	aConcreteLBZ := self lbz inEnvironment:
		(Dictionary newFromPairs: 
			#('d'   16r1234
			  'rt'  1
			  'ra'  2)). 
	self assert: ( aConcreteLBZ alwaysFitsBinary: 16r88221234///32 )
]

{ #category : #'tests - concrete instructions' }
AcSymbolicDecodeTest >> test88221234CanFitConcreteLBZ [
	| aConcreteLBZ |
	aConcreteLBZ := self lbz inEnvironment:
		(Dictionary newFromPairs: 
			#('d'  16r1234
			  'rt' 1
			  'ra' 2)).            
	self assert: ( aConcreteLBZ canFitBinary: 16r88221234///32 )
]

{ #category : #tests }
AcSymbolicDecodeTest >> testAnyOpcode34FitsLBZ [
	"Prove that anything starting with opcode=34, fits."
	self assert: ( self lbz alwaysFitsBinary: 34///6, ('x'///(32-6)) )
]

{ #category : #tests }
AcSymbolicDecodeTest >> testFFFFFFFFNeverFits [
	self deny: ( self lbz canFitBinary: 16rFFFFFFFF///32 )
]

{ #category : #tests }
AcSymbolicDecodeTest >> testXAlwaysFits [
	"Disprove that the judgement
		'x is the encoding of lbz'
	is valid.	"
	self deny: ( self lbz alwaysFitsBinary: 'x'///32 )
]

{ #category : #'tests - concrete instructions' }
AcSymbolicDecodeTest >> testXAlwaysFitsConcreteLBZ [
	| aConcreteLBZ |
	aConcreteLBZ := self lbz inEnvironment:
		(Dictionary newFromPairs: 
			#('d'  16r1234
			  'rt' 1
			  'ra' 2)).
	self deny: ( aConcreteLBZ alwaysFitsBinary: 'x'///32 )
]

{ #category : #tests }
AcSymbolicDecodeTest >> testXCanFit [
	"Prove that the judgement
		'x is the encoding of lbz'
	is not inconsistent
	(i.e., there are some x which are indeed encodings of lbz.	"
	self assert: ( self lbz canFitBinary: 'x'///32 )
]

{ #category : #'tests - concrete instructions' }
AcSymbolicDecodeTest >> testXCanFitConcreteLBZ [
	| aConcreteLBZ |
	aConcreteLBZ := self lbz inEnvironment:
		(Dictionary newFromPairs: 
		   #('d'  16r1234
			 'rt' 1
			 'ra' 2)).            
	self assert: ( aConcreteLBZ canFitBinary: 'x'///32 )
]
