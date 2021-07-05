Class {
	#name : #Special8bitCharacterTest,
	#superclass : #TestCase,
	#category : #'ArchC-LibreSOC-Tests'
}

{ #category : #tests }
Special8bitCharacterTest >> extensionSymbols [
	^(Character class organization protocolNamed: '*ArchC-LibreSOC') methodSelectors
]

{ #category : #tests }
Special8bitCharacterTest >> testArchCExtensions [
	| syms assocs d |
	syms := self extensionSymbols.
	assocs := syms collect: [ :sym | (Character perform: sym) -> sym asString ].
	d := Dictionary newFromAssociations: assocs asArray.
	self assert: syms size equals:  d size
	"d inspect"
]
