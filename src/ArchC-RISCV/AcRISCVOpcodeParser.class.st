Class {
	#name : #AcRISCVOpcodeParser,
	#superclass : #AcCommonParser,
	#category : #'ArchC-RISCV-Parsing'
}

{ #category : #parsing }
AcRISCVOpcodeParser class >> parseFile: filename [
	^ self parseFile: filename in: '/' 

]

{ #category : #parsing }
AcRISCVOpcodeParser class >> parseFile: fileName in: path [
	| f s |
	f := FileStream fileNamed:
		path,
		'/',
		fileName.
	s := f contentsOfEntireFile.
	f close.
	^(self inWorkingDirectory: path)
		parse: s

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
AcRISCVOpcodeParser >> funct7 [
	^ ('31..25=' asParser , self number) trim ==> [ :nodes | nodes second ]

	"
	 AcRISCVOpcodeParser parse: '31..25=32 ' startingAt: #func7"

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
		instr addMnemonic: '("' , nodes first , ' %gpr, %gpr, %exp(bimm16)", rs1, rs2, imm1+imm2+imm3+imm4)'.

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

		| internalBindings instr |

		internalBindings := Dictionary new.
		internalBindings at: 'funct3' put: (nodes at: 5).
		internalBindings at: 'opcode' put: (nodes at: 6).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_I'.
		instr internalBindings: internalBindings.  
		instr addMnemonic: '("' , nodes first , ' %gpr, %gpr, %exp", rd, rs1, imm)'.

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
		instr addMnemonic: '("' , nodes first , ' %gpr, %gpr, %imm", rd, rs1, imm)'.

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
		instr addMnemonic: '("' , nodes first , ' %gpr, %gpr, %imm", rd, rs1, shamt)'.

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
		instr addMnemonic: '("' , nodes first , ' %gpr, %gpr, %imm", rd, rs1, shamtw)'.

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
		instr addMnemonic: '("' , nodes first , '")'.

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
		instr addMnemonic: '("' , nodes first , ' %gpr, %exp(bimm16)", rd, imm1+imm2+imm3+imm4)'.

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
		instr addMnemonic: '("' , nodes first , ' %gpr, %gpr, %gpr", rd, rs1, rs2)'.

		instr
		]

	"
	AcRISCVOpcodeParser parse: 'add     rd rs1 rs2 31..25=0  14..12=0 6..2=0x0C 1..0=3' startingAt: #type_R
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
		instr addMnemonic: '("' , nodes first , ' %gpr, %gpr", rs1, rs2)'.

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

		| internalBindings instr |

	   internalBindings := Dictionary new.
		internalBindings at: 'funct3' put: (nodes at: 6).
		internalBindings at: 'opcode' put: (nodes at: 7).

		instr := ProcessorInstructionDeclaration new.
		instr name: nodes first.
		instr format: 'Type_S'.
		instr internalBindings: internalBindings.
		instr addMnemonic: '("' , nodes first , ' %gpr, %gpr, %exp", rd, rs1, imm1+imm2+imm3)'.

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
		instr addMnemonic: '("' , nodes first , ' %gpr, %exp", rd, imm)'.

		instr
		]


	"
	AcRISCVOpcodeParser parse: 'lui     rd imm20 6..2=0x0D 1..0=3' startingAt: #type_U
	"

]
