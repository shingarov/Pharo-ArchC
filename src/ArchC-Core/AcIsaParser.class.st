"
I parse <isaname>_isa.ac files.
"
Class {
	#name : #AcIsaParser,
	#superclass : #AcCommonParser,
	#instVars : [
		'asmMap',
		'asmMapBody',
		'assemblerComment',
		'associationList',
		'behavior',
		'cstorStatement',
		'cond',
		'ctor',
		'idEqualNumber',
		'instructionStatement',
		'isBranch',
		'isJump',
		'setAsm',
		'setDecoder',
		'setCycles',
		'percentId',
		'format',
		'isa',
		'instr',
		'rangeSubscript',
		'quotedOptionalReg',
		'quotedOptionalRegList',
		'pseudoInstr',
		'helper',
		'delay',
		'bitfield',
		'pseudoInstrConstituent',
		'delayCond',
		'strList',
		'asmMapBody1',
		'asmMapBody2',
		'riscvOpcodes'
	],
	#category : #'ArchC-Core-Parsing'
}

{ #category : #'as yet unclassified' }
AcIsaParser class >> constructAsmMap: assocs [
	"For disassembly purposes, select the most specific symbolic names
	in a map.  For example, on SPARC, GPR %o1 is also called %r9.
	Of course, we can't know the intended symbolic form, but we at least
	attempt to say that %o1 is kind of more descriptive than %r9.
	
	This method works at the level of one map.  Assocs is a collection
	in which 	each element came from parsing one line (aka one map body).
	Each body then gives a collection of one (Form 1) or many individual
	arrows, which do not exist at the syntactic level.  For example,
	9->'%r9' is an arrow of cardinality 32, 9->'o1' has cardinality 8,
	and 14->'%sp' has cardinality 1.
	
	Answer a Dictionary mapping ints to the symbols of least cardinality
	(e.g., 9->'o1'). "
	| cardinalities answer |
	cardinalities := Dictionary new.
	answer := Dictionary new.
	assocs do: [ :aMapBody |
		aMapBody do: [ :crdIntSym "cardinality->int->sym" |
			| existingCardinality cardinality int sym |
			cardinality := crdIntSym key.
			int := crdIntSym value key.
			sym := crdIntSym value value.
			existingCardinality := cardinalities at: int ifAbsent: [-1].
			existingCardinality == -1 ifTrue: [ "Brand new"
				cardinalities at: int put: cardinality.
				answer at: int put: sym ]
			ifFalse: [ "Already exists, let's see if ours is better"
				existingCardinality > cardinality ifTrue: [
					cardinalities at: int put: cardinality.
					answer at: int put: sym ] ] ] ].
	^answer
]

{ #category : #grammar }
AcIsaParser >> asmMap [
	"An 'asmmapdec' of the form,
	
	AC_ASM_MAP id LBRACE mapbodylist RBRACE
	
	The asmmapdec object in Smalltalk associates the id to the
	Dictionary representing the mapbodylist.
	Return an array with an association from 'ac_map'
	to the asmmapdec, so that as a final step all maps are
	combined into one dictionary (see #)."
	^'ac_asm_map' asParser trim,
	id,
	#space asParser star,
	${ asParser,
	asmMapBody trim plus,
	$} asParser
	==> [ :x |
		| name entries map |
		name := x second.
		entries := x fifth flattened.
		map := AcAsmMap name: name entries: entries.
		Array with: 'ac_map' -> map ]
]

{ #category : #grammar }
AcIsaParser >> asmMapBody [
	"There are 4 forms of asmMapBody:
	(1)  STR symbolList = i;
	(2)  STR[i..i] = [i..i];
	(3)  [i..i]STR = [i..i]; (Not used in any model)
	(4)  STR[i..i]STR = [i..i];  (Not used in any model) "
	^asmMapBody1 / asmMapBody2
]

{ #category : #grammar }
AcIsaParser >> asmMapBody1 [
	"Map body, Form 1: symbolList = int;        "
	^strList,
	$= asParser trim,
	number,
	$; asParser
	==> [ :x |
		| names value |
		names := x first.
		value := x third.
		names collect: [ :name | AcAsmMapEntry name: name value: value ]
		]
]

{ #category : #grammar }
AcIsaParser >> asmMapBody2 [
	"Map body, Form 2:  STR[i..i] = [i..i]; "
	^str,
	rangeSubscript,
	$= asParser trim,
	rangeSubscript,
	$; asParser
	==> [ :x |
		| name lhsRange rhsRange entries |
		name := x first.
		lhsRange := x second.
		rhsRange := x fourth.
		lhsRange size = rhsRange size ifFalse: [ self error: lhsRange incommensurable: rhsRange ].
		entries := (0 to: lhsRange size - 1) 
						collect: [ :i | AcAsmMapEntry name: name , (lhsRange first + i) printString 
														value: (rhsRange first + i) 
														cardinality: rhsRange size ].
		entries
		]
]

{ #category : #grammar }
AcIsaParser >> assemblerComment [
	^('assembler.set_comment' asParser / 'assembler.set_line_comment' asParser) trim,
	matchedParen trim,
	';' asParser trim
	==> [ :x | 'assembler_comment' -> #() ]
]

{ #category : #'as yet unclassified' }
AcIsaParser >> associationList [
	^ idEqualNumber,
	(($, asParser trim, idEqualNumber ==> [ :x | x second ]) star
		==> [ :x | self associations2dictionary: x ])
	==> [ :x | x second add: (x first); yourself ]
]

{ #category : #'as yet unclassified' }
AcIsaParser >> associations2dictionary: associations [
	| d |
	d := Dictionary new.
	associations  do: [ :anAssociation | d add: anAssociation  ].
	^d
]

{ #category : #grammar }
AcIsaParser >> behavior [
	^id,
	'.behavior' asParser,
	matchedParen,
	$; asParser
	==> [ :x |
		'ac_behavior' -> (x first -> x third) ]
]

{ #category : #grammar }
AcIsaParser >> bitfield [
	"Instruction encoding fields like %opcode:6."
	
	^ ((percentId / number) , $: asParser , number , ':s' asParser optional) 
		==> [:nodes | AcInstructionBitfield name: nodes first width: nodes third signed: nodes fourth notNil ]

]

{ #category : #grammar }
AcIsaParser >> cond [
	^id,
	'.cond' asParser,
	matchedParen,
	$; asParser
	==> [ :x | 'cond' -> #() ]
]

{ #category : #grammar }
AcIsaParser >> cstorStatement [
	^setAsm /
	setDecoder /
	setCycles /
	isJump /
	isBranch /
	behavior /
	cond /
	delay /
	delayCond /
	pseudoInstr /
	assemblerComment

]

{ #category : #grammar }
AcIsaParser >> ctor [
	^'ISA_CTOR(' asParser,
	id,
	')' asParser trim,
	'{' asParser trim,
	cstorStatement trim star,
	'};' asParser trim
	==> [ :x | x at: 5 ]

]

{ #category : #grammar }
AcIsaParser >> delay [
	^id,
	'.delay(' asParser,
	decimalNumber,
	');' asParser
	==> [ :x | 'delay' -> x ]
]

{ #category : #grammar }
AcIsaParser >> delayCond [
	^id,
	'.delay_cond' asParser,
	matchedParen,
	$; asParser
	==> [ :x | 'delay_cond' -> #() ]
]

{ #category : #grammar }
AcIsaParser >> error: l incommensurable: r [
	self error: l printString, ' incommensurable to ', r printString
]

{ #category : #grammar }
AcIsaParser >> format [
	^'ac_format' asParser,
	#space asParser star,
	id,
	$= asParser trim,
	$" asParser, bitfield trim plus, '";' asParser
	==> [ :x | Array with: 'ac_format' -> (AcInstructionFormat name: x third bitfields: x sixth) ]
]

{ #category : #grammar }
AcIsaParser >> helper [
	^'ac_helper {' asParser trim,
	'};' asParser negate star,
	'};' asParser
	==> [ :x | #() ]
]

{ #category : #grammar }
AcIsaParser >> idEqualNumber [
	^id , $= asParser trim, number
	==> [ :x | Association key: x first value: x last ]
]

{ #category : #grammar }
AcIsaParser >> instr [
	^'ac_instr<' asParser,
	id,
	$> asParser,
	#space asParser star,
	idList,
	$; asParser
	==> [ :x |
		| format instrs  |
		format := x second.
		instrs := x fifth.
		instrs collect: [ :name |
			| instr |

			instr := ProcessorInstructionDeclaration new.
			instr name: name.
			instr format: format.
			'ac_instr' -> instr
		] ]
]

{ #category : #grammar }
AcIsaParser >> instructionStatement [
	^instr /
	format /
	asmMap /
	ctor /
	helper /
	riscvOpcodes

]

{ #category : #grammar }
AcIsaParser >> isBranch [
	^id,
	'.is_branch' asParser,
	matchedParen,
	$; asParser
	==> [ :x | 'is_branch' -> x ]
]

{ #category : #grammar }
AcIsaParser >> isJump [
	^id,
	'.is_jump' asParser,
	matchedParen,
	$; asParser
	==> [ :x | 'is_jump' -> x ]
]

{ #category : #grammar }
AcIsaParser >> isa [
	^'AC_ISA(' asParser trim,
	id,
	')' asParser trim,
	'{' asParser trim,
	instructionStatement trim star,
	'};' asParser trim
	==> [ :x | x at: 5 ]

]

{ #category : #grammar }
AcIsaParser >> percentId [
	^$% asParser, id
	==> [ :x | x last ]
]

{ #category : #grammar }
AcIsaParser >> pseudoInstr [
	"Pseudo instructions are only useful constructing the assembler"
	^'pseudo_instr' asParser trim,
	matchedParen,
	${ asParser trim,
	pseudoInstrConstituent trim star,
	$} asParser
	==> [ :x | 'pseudo_instr' -> #BOGUS ]
]

{ #category : #grammar }
AcIsaParser >> pseudoInstrConstituent [
	^'"' asParser,
	'";' asParser negate star,
	'";' asParser
]

{ #category : #grammar }
AcIsaParser >> quotedOptionalReg [
	^$" asParser,
	(registerName / '$' asParser) optional,
	$" asParser
]

{ #category : #grammar }
AcIsaParser >> quotedOptionalRegList [
	^quotedOptionalReg,
	($, asParser trim, quotedOptionalReg ) star
]

{ #category : #grammar }
AcIsaParser >> rangeSubscript [
	^$[ asParser,
	number,
	'..' asParser,
	number,
	$] asParser
	==> [ :x | x second to: x fourth ]
]

{ #category : #grammar }
AcIsaParser >> riscvOpcodes [
	"Pharo-ArchC extension - read RISC-V instructions from
	 upstream RISC-V opcodes definition [1].

	 [1] https://github.com/riscv/riscv-opcodes
	"

	^'_ac_riscv_opcodes("' asParser, $" asParser negate star flatten, '");' asParser
	==>	[ :x | 

		| riscvOpcodesParser |

		riscvOpcodesParser := Smalltalk at: #AcRISCVOpcodeParser 
					  ifAbsent: [ self error: 'No RISC-V opcodes parser, please load package ArchC-RISCV' ].
		riscvOpcodesParser parseFile: x second in: directory 
		]   

]

{ #category : #grammar }
AcIsaParser >> setAsm [
	^id,
	'.set_asm' asParser trim,
	matchedParen,
	';' asParser
	==> [ :x |
		"At this stage we don't process the set_asm directive,
		we just store the whole line -- i.e. everything between the (),
		including the format and arguments, taking note which instruction it is"
		'set_asm' -> (x first -> x third) ]
]

{ #category : #grammar }
AcIsaParser >> setCycles [
	^id,
	'.set_cycles(' asParser,
	decimalNumber,
	');' asParser
	==> [ :x | 'set_cycles' -> (x first -> x third) ]
]

{ #category : #grammar }
AcIsaParser >> setDecoder [
	^id,
	'.set_decoder' asParser,
	$  asParser star,
	$( asParser,
	$  asParser star,
	associationList,
	');' asParser trim
	==> [ :x | 'set_decoder' -> (x first -> x sixth) ]
]

{ #category : #grammar }
AcIsaParser >> start [
	^isa end
		==> [ :x | x asOrderedCollection
			inject: OrderedCollection new
			into: [ :soFar :elem | soFar addAll: elem; yourself ]]
]

{ #category : #grammar }
AcIsaParser >> strList [
	^str,
	(($, asParser trim, str) ==> [ :commaStr | commaStr second ]) star
	==> [ :x |
		| initial rest |
		initial := OrderedCollection  with: x first.
		rest := x last.
		initial addAllLast: rest.
		initial
	 ]
]
