Class {
	#name : #AcMnemonicFormatParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'percentId',
		'imm'
	],
	#classInstVars : [
		'maps'
	],
	#category : #'ArchC-Parsing'
}

{ #category : #parsing }
AcMnemonicFormatParser class >> maps [
	^maps
]

{ #category : #'instance creation' }
AcMnemonicFormatParser class >> maps: m [
	"The argument here is the final result of parsing
	the ac_asm_map statements in *_isa.ac.
	"
	"TODO -- EXTREMELY BAD.
	I am not sure how to parametrize a parser when productions depend on the parametrization."
	maps := m.
	^ self new
]

{ #category : #grammar }
AcMnemonicFormatParser >> imm [
	^ '%imm' asParser / '%exp' asParser / '%addr' asParser ==> [ :immToken |
		[ :operands :stream |
			stream nextPutAll: '0x'.
			operands removeFirst printOn: stream base: 16 showRadix: false]]
]

{ #category : #grammar }
AcMnemonicFormatParser >> percentId [
	| p |
	p := imm.
	self class maps keysAndValuesDo: [ :mapName :map |
		p := p / (('%', mapName) asParser / ('%[', mapName, ']') asParser ==>
		[ :r | [ :operands :stream | stream nextPutAll: (map at: (operands removeFirst)) ]])].
	^ p
]

{ #category : #grammar }
AcMnemonicFormatParser >> start [
	"The result of parsing a format string is a 1-argument block which,
	 given an ordered collection of operand values,
	 answers a string of disassembly."
	| normal escape |
	normal := (PPPredicateObjectParser anyExceptAnyOf: '%\"') ==> [ :char |
		[ :env :stream | stream nextPut: char ] ].
	escape := '\%' asParser ==> [ :x | [ :y :stream | stream nextPut: $% ]].
	^ (normal / escape / percentId) star end ==> [ :blocks |
		"An array of 2-argument blocks, each block takes (1) an ordered collection
		 of operand values and (2) a stream onto which to print the piece of
		 disassembly corresponding to this element of the array."
		[  :env |
		| stream |
		stream := WriteStream on: String new.
		blocks do: [ :block | block value: env value: stream ].
		stream contents ]]
]
