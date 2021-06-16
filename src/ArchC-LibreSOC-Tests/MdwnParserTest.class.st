Class {
	#name : #MdwnParserTest,
	#superclass : #TestCase,
	#category : #'ArchC-LibreSOC-Tests'
}

{ #category : #tests }
MdwnParserTest >> testParseBranch [
	| page branch |
	page := MdwnParser parse: 'branch'. "Array with 5 Mdwninstructions"
	self assert: page size equals: 5.
	branch := page detect: [ :op | op desc = 'Branch' ].
	self assert: branch opcodes size equals: 4. "b, ba, bl, bla"
	
]

{ #category : #tests }
MdwnParserTest >> testParseFixedArith [
	| page branch |
	page := MdwnParser parse: 'fixedarith'. "Array with 41 Mdwninstructions"
	self assert: page size equals: 41.
	branch := page detect: [ :op | op desc = 'Subtract From' ].
	self assert: branch opcodes size equals: 4. "subf, subf., subfo, subfo. "
	
]
