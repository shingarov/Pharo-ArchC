Class {
	#name : #AcIsaStatementParseTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests-Parsing'
}

{ #category : #tests }
AcIsaStatementParseTest >> parseStatement: aString [
	| result |
	result := AcIsaParser new
		parse: 'AC_ISA(test) { ', aString, ' };'.
	^result first

]

{ #category : #tests }
AcIsaStatementParseTest >> testInstructionFormat [
	| result format operandFields firstField |
	result := self parseStatement: 'ac_format I1 = "%opcd:6 %li:24:s %aa:1 %lk:1";'.
	self assert: result key equals: 'ac_format'.
	format := result value.
	self assert: format key equals: 'I1'.
	operandFields := format value.
	firstField := operandFields first.
	self assert: firstField key equals: 'opcd'.
	self assert: firstField value equals: 6.
]
