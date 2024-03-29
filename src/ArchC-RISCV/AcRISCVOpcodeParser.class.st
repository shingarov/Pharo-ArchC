Class {
	#name : #AcRISCVOpcodeParser,
	#superclass : #AcCommonParser,
	#category : #'ArchC-RISCV-Parsing'
}

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> aqrl [
	^ 'aqrl' asParser trim
]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> bimm12hi [
	^ 'bimm12hi' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> bimm12lo [
	^ 'bimm12lo' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> fm [
	^ 'fm' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> fmt [
	^ ('26..25=' asParser , self number) trim ==> [ :nodes | nodes second ]

	"
	AcRISCVOpcodeParser parse: '26..25=0 ' startingAt: #fmt
	"
]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> funct12 [
	^ ('31..20=' asParser , self number) trim ==> [ :nodes | nodes second ]

	"
	AcRISCVOpcodeParser parse: '31..20=0x002 ' startingAt: #funct12
	"

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> funct3 [
	^ ('14..12=' asParser , self number) trim ==> [ :nodes | nodes second ]

	"
	 AcRISCVOpcodeParser parse: ' 14..12=1 ' startingAt: #funct3
	"

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> funct5 [
	^ ('31..27=' asParser , self number) trim ==> [ :nodes | nodes second ]

	"
	AcRISCVOpcodeParser parse: '31..27=32 ' startingAt: #funct5
	"
]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> funct5_h3 [
	^ ('31..29=' asParser , self number) trim ==> [ :nodes | nodes second ]
]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> funct5_l2 [
	^ ('28..27=' asParser , self number) trim ==> [ :nodes | nodes second ]
]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> funct7 [
	^ ('31..25=' asParser , self number) trim ==> [ :nodes | nodes second ]

	"
	 AcRISCVOpcodeParser parse: '31..25=32 ' startingAt: #func7"

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> funct_rs2 [
	^ ('24..20=' asParser , self number) trim ==> [ :nodes | nodes second ]
]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> imm12 [
	^ 'imm12' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> imm12hi [
	^ 'imm12hi' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> imm12lo [
	^ 'imm12lo' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> imm20 [
	^ 'imm20' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> jimm20 [
	^ 'jimm20' asParser trim

]

{ #category : #'parsing - utils' }
AcRISCVOpcodeParser >> mnemonic [
	^ (#letter asParser / $. asParser) star ==> [ :chars | String withAll: chars ]

	"
	AcRISCVOpcodeParser parse: 'addi' startingAt: #mnemonic
	AcRISCVOpcodeParser parse: 'fcvt.x.d' startingAt: #mnemonic
	"

]

{ #category : #'parsing - utils' }
AcRISCVOpcodeParser >> number [
	^ hexNumber / decimalNumber 

	"
	AcRISCVOpcodeParser parse: '123' startingAt: #number
	AcRISCVOpcodeParser parse: '0x0C' startingAt: #number
	"

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> opcode [
	^ ('6..2=' asParser  , self number) trim , ('1..0=' asParser  , self number) trim
	==> [ :nodes | (nodes first second bitShift: 2) bitOr: nodes second second ]

	"
	AcRISCVOpcodeParser parse: ' 6..2=0x0C 1..0=3' startingAt: #opcode
	"

]

{ #category : #parsing }
AcRISCVOpcodeParser >> parse: anObject [
	| stream instructions |

	stream := anObject readStream.
	instructions := OrderedCollection new.
	[ stream atEnd ] whileFalse: [ 
		| line |

		line := stream nextLine.
		(line notEmpty and:[line first ~~ $#]) ifTrue: [
			| instruction |

			instruction := super parse: line.
			self assert: instruction isPetitFailure not.
			instructions add: 'ac_instr' -> instruction.
		].
	].
	^ instructions

	"
	AcRISCVOpcodeParser parseFile: (AcProcessorDescriptions baseDirectory , 'riscv/riscv-opcodes/opcodes-rv32i')
	"

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> pred [
	^ 'pred' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> rd [
	^ 'rd' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> rd0 [
	^ '11..7=0' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> rm [
	^ ('rm' asParser trim ==> [ :nodes | nil ])
	/ (('14..12=' asParser , self number) trim ==> [ :nodes | nodes second ])

	"
	AcRISCVOpcodeParser new rm
	"
]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> rs1 [
	^ 'rs1' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> rs10 [
	^ '19..15=0' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> rs2 [
	^ 'rs2' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> rs3 [
	^ 'rs3' asParser trim
]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> shamt [
	^  'shamt' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> shamtw [
	^  'shamtw' asParser trim

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> shfun [
	^ ('31..26=' asParser , self number) trim ==> [ :nodes | nodes second ]

	"
	AcRISCVOpcodeParser parse: '31..26=16' startingAt: #shfun
	AcRISCVOpcodeParser parse: '31..25=16' startingAt: #shfun
	"

]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> shfunw [
	^ ('31..25=' asParser , self number) trim ==> [ :nodes | nodes second ]

	"
	AcRISCVOpcodeParser parse: '31..26=16' startingAt: #shfunw
	AcRISCVOpcodeParser parse: '31..25=16' startingAt: #shfunw
	"

]

{ #category : #parsing }
AcRISCVOpcodeParser >> start [
	^ 
	  self type_R
	/ self type_Rsys
	/ self type_Rfd
	/ self type_R4fd
	/ self type_Ra

	/ self type_Ish
	/ self type_Ishw
	/ self type_Ifence
	/ self type_Isys
	/ self type_I

	/ self type_S
	/ self type_B

	/ self type_U
	/ self type_J


	"
	AcRISCVOpcodeParser parse: 'andi    rd rs1 imm12           14..12=7 6..2=0x04 1..0=3' startingAt: #type_I
	AcRISCVOpcodeParser parse: 'slli    rd rs1 31..26=0  shamt 14..12=1 6..2=0x04 1..0=3' startingAt: #type_I
	AcRISCVOpcodeParser parse: 'srai    rd rs1 31..26=16 shamt 14..12=5 6..2=0x04 1..0=3' startingAt: #type_Ish    
	AcRISCVOpcodeParser parse: 'sb     imm12hi rs1 rs2 imm12lo 14..12=0 6..2=0x08 1..0=3' startingAt: #type_S
	AcRISCVOpcodeParser parse: '11..7=0 19..15=0 31..20=0x001 14..12=0 6..2=0x1C 1..0=3' startingAt: #type_Isys

	AcRISCVOpcodeParser parseFile: (AcProcessorDescriptions baseDirectory , 'riscv/riscv-opcodes/opcodes-rv32i')
	AcRISCVOpcodeParser parseFile: (AcProcessorDescriptions baseDirectory , 'riscv/riscv-opcodes/opcodes-rv64i')
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> strip: aStringOrStream [
	^ aStringOrStream readStream
]

{ #category : #'parsing - bitfields' }
AcRISCVOpcodeParser >> succ [
	^ 'succ' asParser trim

]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_B [
	^ (self mnemonic , self bimm12hi , self rs1, self rs2 , self bimm12lo , self funct3 , self opcode)
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'funct3' put: (nodes at: 6).
		internalBindings at: 'opcode' put: (nodes at: 7).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_B'.
		instr internalBindings: internalBindings.  
		instr addSyntax: '("' , nodes first , ' %gpr, %gpr, %exp(bimm16)", rs1, rs2, imm1+imm2+imm3+imm4)'.

		instr
		]


	"
	AcRISCVOpcodeParser parse: 'bgeu    bimm12hi rs1 rs2 bimm12lo 14..12=7 6..2=0x18 1..0=3' startingAt: #type_B
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_I [
	^ ((self mnemonic , self rd , self rs1, self imm12, self funct3 , self opcode)
	==> [ :nodes |

		| opcode internalBindings instr |

		opcode := nodes at: 6.

		internalBindings := Dictionary new.
		internalBindings at: 'funct3' put: (nodes at: 5).
		internalBindings at: 'opcode' put: opcode.

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_I'.
		instr internalBindings: internalBindings.

		opcode == 3 ifTrue: [ 
			"This instruction is a load into GPR"
			instr addSyntax: '("' , nodes first , ' %gpr, %exp(%gpr)", rd, imm, rs1)'.
		] ifFalse: [ 
		opcode == 7 ifTrue: [
			"This instruction is a load into FPR"
			instr addSyntax: '("' , nodes first , ' %fpr, %exp(%gpr)", rd, imm, rs1)'.
		] ifFalse: [ 
			instr addSyntax: '("' , nodes first , ' %gpr, %gpr, %exp", rd, rs1, imm)'.
		]].
		instr
		])
	/ ((self mnemonic , self imm12, self rs1, self funct3 , self rd, self opcode)
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'funct3' put: (nodes at: 4).
		internalBindings at: 'opcode' put: (nodes at: 5).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_I'.
		instr internalBindings: internalBindings.  
		instr addSyntax: '("' , nodes first , ' %gpr, %gpr, %imm", rd, rs1, imm)'.

		instr
		])


	"
	AcRISCVOpcodeParser parse: 'andi    rd rs1 imm12           14..12=7 6..2=0x04 1..0=3' startingAt: #type_I
	AcRISCVOpcodeParser parse: 'add     rd rs1 rs2 31..25=0  14..12=0 6..2=0x0C 1..0=3' startingAt: #type_I
	AcRISCVOpcodeParser parse: 'fence.i     imm12                       rs1 14..12=1 rd 6..2=0x03 1..0=3' startingAt: #type_I
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_Ifence [
	^ self mnemonic , self fm, self pred, self succ , self rs1, self funct3 , self rd , self opcode
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'funct3' put: (nodes at: 6).
		internalBindings at: 'opcode' put: (nodes at: 8).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_Ifence'.
		instr internalBindings: internalBindings.  
"         instr addMnemonic: '('' , nodes first , ' %reg, %reg, %reg', rd, rs1, rs2)'."

		instr
		]


	"
	AcRISCVOpcodeParser parse: 'fence       fm            pred succ     rs1 14..12=0 rd 6..2=0x03 1..0=3' startingAt: #type_Ifence
	"

]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_Ish [
	^ self mnemonic , self rd , self rs1, self shfun, self shamt, self funct3 , self opcode
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'shfun' put: (nodes at: 4).
		internalBindings at: 'funct3' put: (nodes at: 6).
		internalBindings at: 'opcode' put: (nodes at: 7).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_Ish'.
		instr internalBindings: internalBindings.  
		instr addSyntax: '("' , nodes first , ' %gpr, %gpr, %imm", rd, rs1, shamt)'.

		instr
		]


	"
	AcRISCVOpcodeParser parse: 'srai    rd rs1 31..26=16 shamt 14..12=5 6..2=0x04 1..0=3' startingAt: #type_Ish
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_Ishw [
	^ self mnemonic , self rd , self rs1, self shfunw, self shamtw, self funct3 , self opcode
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'shfunw' put: (nodes at: 4).
		internalBindings at: 'zerobit' put: 0.
		internalBindings at: 'funct3' put: (nodes at: 6).
		internalBindings at: 'opcode' put: (nodes at: 7).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_Ishw'.
		instr internalBindings: internalBindings.
		instr addSyntax: '("' , nodes first , ' %gpr, %gpr, %imm", rd, rs1, shamtw)'.

		instr
		]


	"
	AcRISCVOpcodeParser parse: 'slliw   rd rs1 31..25=0  shamtw 14..12=1 6..2=0x06 1..0=3' startingAt: #type_Ish
	AcRISCVOpcodeParser parse: 'slliw   rd rs1 31..25=0  shamtw 14..12=1 6..2=0x06 1..0=3'
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_Isys [
	^ (self mnemonic , self rd0 , self rs10, self funct12, self funct3 , self opcode)
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'rd' put: 0.
		internalBindings at: 'rs1' put: 0.
		internalBindings at: 'imm' put: (nodes at: 4).
		internalBindings at: 'funct3' put: (nodes at: 5).
		internalBindings at: 'opcode' put: (nodes at: 6).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_I'.
		instr internalBindings: internalBindings.  
		instr addSyntax: '("' , nodes first , '")'.

		instr
		]


	"
	AcRISCVOpcodeParser parse: 'ebreak 11..7=0 19..15=0 31..20=0x001 14..12=0 6..2=0x1C 1..0=3' startingAt: #type_Isys
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_J [
	^ self mnemonic , self rd , self jimm20, self opcode
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'opcode' put: (nodes at: 4).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_J'.
		instr internalBindings: internalBindings.
		instr addSyntax: '("' , nodes first , ' %gpr, %exp(bimm16)", rd, imm1+imm2+imm3+imm4)'.

		instr
		]


	"
	AcRISCVOpcodeParser parse: 'jal     rd jimm20                          6..2=0x1b 1..0=3
' startingAt: #type_J
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_R [
	^ self mnemonic , self rd , self rs1, self rs2 , self funct7 , self funct3 , self opcode
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'funct7' put: (nodes at: 5).
		internalBindings at: 'funct3' put: (nodes at: 6).
		internalBindings at: 'opcode'put: (nodes at: 7).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_R'.
		instr internalBindings: internalBindings.  
		instr addSyntax: '("' , nodes first , ' %gpr, %gpr, %gpr", rd, rs1, rs2)'.

		instr
		]

	"
	AcRISCVOpcodeParser parse: 'add     rd rs1 rs2 31..25=0  14..12=0 6..2=0x0C 1..0=3' startingAt: #type_R
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_R4fd [
	^ (self mnemonic , self rd , self rs1, self rs2, self rs3 , self rm, self fmt , self opcode
	==> [ :nodes |

		| internalBindings rm instr |

		internalBindings := Dictionary new.
		internalBindings at: 'fmt' put: (nodes at: 7).
		rm := nodes at: 6.
		rm notNil ifTrue: [ 
			internalBindings at: 'rm' put: rm.
		].
		internalBindings at: 'opcode' put: (nodes at: 8).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_R4fd'.
		instr internalBindings: internalBindings.  
		rm isNil ifTrue: [
			instr addSyntax: '("' , nodes first , ' %fpr, %fpr, %fpr, %fpr", rd, rs1, rs2, rs3, rm=7)'.
			instr addSyntax: '("' , nodes first , ' %fpr, %fpr, %fpr, %fpr, %rm", rd, rs1, rs2, rs3, rm)'.
		] ifFalse: [ 
			instr addSyntax: '("' , nodes first , ' %fpr, %fpr, %fpr, %fpr", rd, rs1, rs2, rs3)'.
		].

		instr
		])

	"
	AcRISCVOpcodeParser parse: 'fmadd.s   rd rs1 rs2 rs3 rm 26..25=0 6..2=0x10 1..0=3' startingAt: #type_R4fd

	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_Ra [
	^ (self mnemonic , self rd , self rs1, self rs2 , self aqrl, self funct5_h3, self funct5_l2, self funct3 , self opcode
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'funct5_h3' put: (nodes at: 6).
		internalBindings at: 'funct5_l2' put: (nodes at: 7).
		internalBindings at: 'funct3' put: (nodes at: 8).
		internalBindings at: 'opcode'put: (nodes at: 9).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_Ra'.
		instr internalBindings: internalBindings.  
		instr addSyntax: '("' , nodes first , '%aqrl %gpr, %gpr, %gpr", aqrl, rd, rs1, rs2)'.

		instr
		])
	/ (self mnemonic , self rd , self rs1, self funct_rs2 , self aqrl, self funct5_h3, self funct5_l2, self funct3 , self opcode
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'funct5_h3' put: (nodes at: 6).
		internalBindings at: 'funct5_l2' put: (nodes at: 7).
		internalBindings at: 'funct3' put: (nodes at: 8).
		internalBindings at: 'opcode'put: (nodes at: 9).
		internalBindings at: 'rs2' put: (nodes at: 4).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_Ra'.
		instr internalBindings: internalBindings.  
		instr addSyntax: '("' , nodes first , '%aqrl %gpr, %gpr", aqrl, rd, rs1)'.

		instr
		])
	

	"
	AcRISCVOpcodeParser parse: 'amoadd.w    rd rs1 rs2      aqrl 31..29=0 28..27=0 14..12=2 6..2=0x0B 1..0=3' startingAt: #type_Ra
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_Rfd [
	^ (self mnemonic , self rd , self rs1, self funct_rs2, self funct5 , self rm, self fmt , self opcode
	==> [ :nodes |

		| internalBindings rm instr |

		internalBindings := Dictionary new.
		internalBindings at: 'funct5' put: (nodes at: 5).
		internalBindings at: 'fmt' put: (nodes at: 7).
		internalBindings at: 'rs2' put: (nodes at: 4).
		rm := nodes at: 6.
		rm notNil ifTrue: [ 
			internalBindings at: 'rm' put: rm.
		].
		internalBindings at: 'opcode' put: (nodes at: 8).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_Rfd'.
		instr internalBindings: internalBindings.  
		rm isNil ifTrue: [
			instr addSyntax: '("' , nodes first , ' %fpr, %fpr", rd, rs1, rm=7)'.
			instr addSyntax: '("' , nodes first , ' %fpr, %fpr, %rm", rd, rs1, rm)'.
		] ifFalse: [ 
			instr addSyntax: '("' , nodes first , ' %fpr, %fpr", rd, rs1)'.
		].

		instr
		])
	/ (self mnemonic , self rd , self rs1, self rs2, self funct5 , self rm, self fmt , self opcode
	==> [ :nodes |

		| internalBindings rm instr |

		internalBindings := Dictionary new.
		internalBindings at: 'funct5' put: (nodes at: 5).
		internalBindings at: 'fmt' put: (nodes at: 7).
		rm := nodes at: 6.
		rm notNil ifTrue: [ 
			internalBindings at: 'rm' put: rm.
		].
		internalBindings at: 'opcode' put: (nodes at: 8).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_Rfd'.
		instr internalBindings: internalBindings.  
		rm isNil ifTrue: [
			instr addSyntax: '("' , nodes first , ' %fpr, %fpr, %fpr", rd, rs1, rs2, rm=7)'.
			instr addSyntax: '("' , nodes first , ' %fpr, %fpr, %fpr, %rm", rd, rs1, rs2, rm)'.
		] ifFalse: [ 
			instr addSyntax: '("' , nodes first , ' %fpr, %fpr, %fpr", rd, rs1, rs2)'.
		].

		instr
		])

	"
	AcRISCVOpcodeParser parse: 'fadd.s    rd rs1 rs2      31..27=0x00 rm       26..25=0 6..2=0x14 1..0=3' startingAt: #type_Rfd
	AcRISCVOpcodeParser parse: 'fsqrt.s   rd rs1 24..20=0 31..27=0x0B rm       26..25=0 6..2=0x14 1..0=3' startingAt: #type_Rfd

	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_Rsys [
	^ self mnemonic , self rd0 , self rs1, self rs2 , self funct7 , self funct3 , self opcode
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'rd' put: 0.
		internalBindings at: 'funct7' put: (nodes at: 5).
		internalBindings at: 'funct3' put: (nodes at: 6).
		internalBindings at: 'opcode'put: (nodes at: 7).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_R'.
		instr internalBindings: internalBindings.  
		instr addSyntax: '("' , nodes first , ' %gpr, %gpr", rs1, rs2)'.

		instr
		]

	"
	AcRISCVOpcodeParser parse: 'sfence.vma 11..7=0 rs1 rs2 31..25=0x09  14..12=0 6..2=0x1C 1..0=3' startingAt: #type_Rsys
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_S [
	^ self mnemonic , self imm12hi , self rs1, self rs2 , self imm12lo , self funct3 , self opcode
	==> [ :nodes |

		| opcode internalBindings instr |

		opcode := nodes at: 7. 

		internalBindings := Dictionary new.
		internalBindings at: 'funct3' put: (nodes at: 6).
		internalBindings at: 'opcode' put: opcode.

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_S'.
		instr internalBindings: internalBindings.

		opcode == 35 ifTrue: [ 
			"This instruction is a store of GPR"
			instr addSyntax: '("' , nodes first , ' %gpr, %exp(%gpr)", rs2, imm1+imm2, rs1)'.
		] ifFalse: [ 
		opcode == 39 ifTrue: [ 
			"This instruction is a store of FPR"
			instr addSyntax: '("' , nodes first , ' %fpr, %exp(%gpr)", rs2, imm1+imm2, rs1)'.
		] ifFalse: [ 
			self error: 'Unknown store'.
		]].





		instr
		]


	"
	AcRISCVOpcodeParser parse: 'sb     imm12hi rs1 rs2 imm12lo 14..12=0 6..2=0x08 1..0=3' startingAt: #type_S
	"
]

{ #category : #parsing }
AcRISCVOpcodeParser >> type_U [
	^ self mnemonic , self rd , self imm20, self opcode
	==> [ :nodes |

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'opcode' put: (nodes at: 4).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_U'.
		instr internalBindings: internalBindings.
		instr addSyntax: '("' , nodes first , ' %gpr, %exp", rd, imm)'.

		instr
		]


	"
	AcRISCVOpcodeParser parse: 'lui     rd imm20 6..2=0x0D 1..0=3' startingAt: #type_U
	"
]
