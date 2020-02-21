"
I represent an AccGen ABI definition, as written in compiler_info.ac 'define abi as...' clause.
"
Class {
	#name : #AcABI,
	#superclass : #Object,
	#instVars : [
		'callingConventions',
		'spReg',
		'fpReg',
		'pcReg',
		'retReg',
		'reservedRegs',
		'auxRegs',
		'pcOffset',
		'stackGrowsAlignment',
		'calleeSaveRegs'
	],
	#category : #'ArchC-Core'
}

{ #category : #accessing }
AcABI >> addCallingConvention: anObject [
	self callingConventions add: anObject 
]

{ #category : #accessing }
AcABI >> auxRegs [
	^ auxRegs
]

{ #category : #accessing }
AcABI >> auxRegs: anObject [
	auxRegs := anObject
]

{ #category : #accessing }
AcABI >> calleeSaveRegs [
	^ calleeSaveRegs
]

{ #category : #accessing }
AcABI >> calleeSaveRegs: anObject [
	calleeSaveRegs := anObject
]

{ #category : #accessing }
AcABI >> callingConventions [
	callingConventions isNil ifTrue: [ callingConventions := Set new ].
	^ callingConventions
]

{ #category : #accessing }
AcABI >> fpReg [
	^ fpReg
]

{ #category : #accessing }
AcABI >> fpReg: anObject [
	fpReg := anObject
]

{ #category : #accessing }
AcABI >> pcOffset [
	^ pcOffset
]

{ #category : #accessing }
AcABI >> pcOffset: anObject [
	pcOffset := anObject
]

{ #category : #accessing }
AcABI >> pcReg [
	^ pcReg
]

{ #category : #accessing }
AcABI >> pcReg: anObject [
	pcReg := anObject
]

{ #category : #accessing }
AcABI >> reservedRegs [
	^ reservedRegs
]

{ #category : #accessing }
AcABI >> reservedRegs: anObject [
	reservedRegs := anObject
]

{ #category : #accessing }
AcABI >> retReg [
	^ retReg
]

{ #category : #accessing }
AcABI >> retReg: anObject [
	retReg := anObject
]

{ #category : #accessing }
AcABI >> spReg [
	^ spReg
]

{ #category : #accessing }
AcABI >> spReg: anObject [
	spReg := anObject
]

{ #category : #accessing }
AcABI >> stackGrowsAlignment [
	^ stackGrowsAlignment
]

{ #category : #accessing }
AcABI >> stackGrowsAlignment: anObject [
	stackGrowsAlignment := anObject
]
