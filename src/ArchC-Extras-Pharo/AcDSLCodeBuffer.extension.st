Extension { #name : #AcDSLCodeBuffer }

{ #category : #'*ArchC-Extras-Pharo' }
AcDSLCodeBuffer >> gtInspectorInstructionsIn: composite [
	<gtInspectorPresentationOrder: 60>

	^ composite fastTable
		title: 'Instructions';
		display: [ 
			| pc insnsWithAddrs |
			
			pc := address.
			insnsWithAddrs := OrderedCollection new: instructions size.
			instructions collect:[:insn |
				insnsWithAddrs add: { insn . pc }.
				pc := pc + (insn bitWidth // 8)
			].
			insnsWithAddrs
		];
		column: 'Address' evaluated: [ :insnAndAddr | insnAndAddr second 	printPaddedWith: $0 to: 6 base: 16  ];
		column: 'Instruction' evaluated: [ :insnAndAddr | insnAndAddr first disassemble ];
		yourself
		"
		selectionPopulate: #selection
			entitled: 'Open key'
			with: [ :table | ( table rawSelection collect: #key ) gtInspectorInterestingObject ];
		beMultiple;
		send: [ :selection | 
			selection
				ifNil: [ nil ]
				ifNotNil: [ selection size = 1
						ifTrue: [ selection anyOne value ]
						ifFalse: [ selection collect: #value ]
					]
			]
		"
]
