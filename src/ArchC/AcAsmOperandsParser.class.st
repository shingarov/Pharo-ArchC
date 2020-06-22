Class {
	#name : #AcAsmOperandsParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'format',
		'operand',
		'operandOrConstraint',
		'constraintConstant',
		'constraintMap',
		'operands',
		'id',
		'decimalNumber',
		'number',
		'hexNumber'
	],
	#classInstVars : [
		'pdl'
	],
	#category : #'ArchC-Parsing'
}

{ #category : #'instance creation' }
AcAsmOperandsParser class >> pdl [
	^ pdl
]

{ #category : #'instance creation' }
AcAsmOperandsParser class >> pdl: p [
	"TODO -- EXTREMELY BAD.
	I am not sure how to parametrize a parser when productions depend on the parametrization."
	"See also AcMnemonicFormatParser class, which gets the maps from me.
	I, in turn, get filled in #fillMnemonicsFrom: which comes from #fillMapsFrom:,
	which is executed on each ISA parse."
	pdl := p.
	^ self new
]

{ #category : #'instance creation' }
AcAsmOperandsParser class >> processAssociation: instrNameToSetAsm in: aPDL [
	| setAsmSource setAsm instructionName instruction |
	instructionName := instrNameToSetAsm key.
	setAsmSource := instrNameToSetAsm value allButLast allButFirst.
	setAsm := (self pdl: aPDL) parse: setAsmSource.
	setAsm source: setAsmSource.
	instruction := aPDL instructions at: instructionName.
	instruction addMnemonic: setAsm.

]

{ #category : #'instance creation' }
AcAsmOperandsParser class >> processAssociations: aCollectionOfAssociations in: aPDL [
	"Take an array of associations from the instruction name
	to the verbatim set_asm directive, parse them and attach
	them to their instructions in the PDL."
	aCollectionOfAssociations do: [ :ass | self processAssociation: ass in: aPDL ].
]

{ #category : #grammar }
AcAsmOperandsParser >> constraintConstant [
	^id, $= asParser, number
	==> [  :x | x first -> x third ]
]

{ #category : #grammar }
AcAsmOperandsParser >> constraintMap [
	^id, $= asParser, id, '.map_to("' asParser,
		(PPPredicateObjectParser anyExceptAnyOf: '"' ) star flatten,
		'")' asParser 	==> [  :x | 
		| map targetOperand arg |
		targetOperand := x first.
		map := self class pdl maps at: x third.
		arg := x fifth.
		targetOperand -> (map lookup: arg) ]
]

{ #category : #grammar }
AcAsmOperandsParser >> decimalNumber [
	^#digit asParser plus flatten ==> [ :x | x asInteger ]
]

{ #category : #grammar }
AcAsmOperandsParser >> format [
	^ ($" asParser,
	(( PPPredicateObjectParser anyExceptAnyOf: '"' ) star flatten ==> [ :x |
		(AcMnemonicFormatParser maps: self class pdl maps) parse: x ]),
	$" asParser) ==> [ :f | f second ]
]

{ #category : #grammar }
AcAsmOperandsParser >> hexNumber [
	^'0x' asParser , #hex asParser star flatten ==> [ :x | Integer readFrom: x second base: 16 ]
]

{ #category : #grammar }
AcAsmOperandsParser >> id [
	^(#letter asParser, ($_ asParser / #word asParser) star) flatten
]

{ #category : #grammar }
AcAsmOperandsParser >> number [
	^ hexNumber / decimalNumber 
]

{ #category : #grammar }
AcAsmOperandsParser >> operand [
	^id, ($+ asParser, operand) optional
	==> [ :x | AsmOperandInstantiation operands: x ]
]

{ #category : #grammar }
AcAsmOperandsParser >> operandOrConstraint [
	^constraintConstant / constraintMap / operand
]

{ #category : #grammar }
AcAsmOperandsParser >> operands [
	^($, asParser trim, operandOrConstraint trim) star ==>
	[  :x | x collect: [ :op | op second  ]]
]

{ #category : #grammar }
AcAsmOperandsParser >> start [
	^operands
]
