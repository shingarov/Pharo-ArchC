"
I parse the 'define abi as...' clause in the compiler_info.ac AccGen semantics description.
"
Class {
	#name : #AcAbiParser,
	#superclass : #AcCommonParser,
	#instVars : [
		'abi',
		'abiDefinition',
		'defineCalleeSave',
		'defineReserved',
		'defineAuxiliar',
		'defineCallingConvention',
		'defineStackPointer',
		'defineFramePointer',
		'defineReturnRegister',
		'defineStackGrows',
		'definePCOffset',
		'defineProgramCounter',
		'convType',
		'stackConventionDef',
		'registerConventionDef'
	],
	#category : #'ArchC-Parsing'
}

{ #category : #grammar }
AcAbiParser >> abi [
	^'define abi as (' asParser,
	abiDefinition trim star,
	');' asParser trim
	==> [ :x |
		| definitions abiObject |
		abiObject := AcABI new.
		definitions := x second.
		definitions do: [ :ass | abiObject perform: ass key with: ass value ].
		abiObject ]
]

{ #category : #grammar }
AcAbiParser >> abiDefinition [
	^defineCalleeSave /
	defineReserved /
	defineAuxiliar /
	defineCallingConvention /
	defineStackPointer /
	defineFramePointer /
	defineReturnRegister /
	defineStackGrows /
	definePCOffset /
	defineProgramCounter
]

{ #category : #grammar }
AcAbiParser >> convType [
	"Either calling or return;
	answer whether it's return (i.e. same is in AcCallingConvention>>#isReturn:"
	^'return' asParser trim ==> [ :x | true ]  /
	'calling' asParser trim ==> [ :x | false ]
]

{ #category : #grammar }
AcAbiParser >> defineAuxiliar [
	^'define auxiliar registers as' asParser trim,
	'(' asParser trim,
	registerListSpaceSeparated,
	');' asParser ==>
	[ :x | #auxRegs: -> x third ]
]

{ #category : #grammar }
AcAbiParser >> defineCalleeSave [
	^'define callee save registers as' asParser trim,
	'(' asParser trim,
	registerListSpaceSeparated,
	');' asParser ==>
	[ :x | #calleeSaveRegs: -> x third ]
]

{ #category : #grammar }
AcAbiParser >> defineCallingConvention [
	^
	'define' asParser,
	convType,
	'convention for' asParser trim,
	id trim,
	'as' asParser trim,
	(registerConventionDef / stackConventionDef),
	$; asParser
	==> [ :x |
		| convention |
		convention := x at: 6.
		convention isReturn: (x second); id: (x fourth).
		#addCallingConvention: -> convention ]

]

{ #category : #grammar }
AcAbiParser >> defineFramePointer [
	^'define framepointer register as' asParser trim,
	registerName trim,
	$; asParser  ==>
	[ :x | #fpReg: -> x second ]
]

{ #category : #grammar }
AcAbiParser >> definePCOffset [
	^'define pcoffset' asParser trim,
	number trim,
	$; asParser ==>
	[ :x | #pcOffset: -> x second ]
]

{ #category : #grammar }
AcAbiParser >> defineProgramCounter [
	^'define programcounter register as' asParser trim,
	registerName trim,
	$; asParser ==>
	[ :x | #pcReg: -> x second ]
]

{ #category : #grammar }
AcAbiParser >> defineReserved [
	^'define reserved registers as' asParser trim,
	'(' asParser trim,
	registerListSpaceSeparated,
	');' asParser ==>
	[ :x | #reservedRegs: -> x third ]
]

{ #category : #grammar }
AcAbiParser >> defineReturnRegister [
	^'define return register as' asParser trim,
	registerName trim,
	$; asParser
	==> [ :x | #retReg: -> x second ]
]

{ #category : #grammar }
AcAbiParser >> defineStackGrows [
	"I have not seen it defined differently on any architecture."
	^'define stack grows' asParser trim,
	(('down' asParser ==> [ :x | -1]) / ('up' asParser ==> [ :x | 1 ])) trim,
	'alignment' asParser trim,
	positiveNumber trim,
	$; asParser ==>
	[ :x | #stackGrowsAlignment: -> (x second * x fourth) ]
]

{ #category : #grammar }
AcAbiParser >> defineStackPointer [
	^'define stackpointer register as' asParser trim,
	registerName trim,
	$; asParser  ==>
	[ :x | #spReg: -> x second ]
]

{ #category : #grammar }
AcAbiParser >> registerConventionDef [
	^$( asParser,
	registerName trim star,
	$) asParser
	==> [ :x |
		AcRegisterCallingConvention new registers: (x second); yourself ]
]

{ #category : #grammar }
AcAbiParser >> stackConventionDef [
	^'stack size' asParser trim,
	positiveNumber trim,
	'alignment' asParser trim,
	positiveNumber
	==> [ :x | AcStackCallingConvention new size: (x second); alignment: (x fourth); yourself ]
]

{ #category : #grammar }
AcAbiParser >> start [
	^abi
]
