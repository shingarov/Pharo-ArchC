Class {
	#name : #AcSetAsmParser,
	#superclass : #Object,
	#instVars : [
		'pdl'
	],
	#category : #'ArchC-Parsing'
}

{ #category : #'instance creation' }
AcSetAsmParser class >> pdl: aPDL [ 
	^self new pdl: aPDL
]

{ #category : #'instance creation' }
AcSetAsmParser class >> processAssociation: instrNameToSetAsm in: aPDL [
	| setAsmSource setAsm instructionName instruction |
	instructionName := instrNameToSetAsm key.
	setAsmSource := instrNameToSetAsm value allButLast allButFirst.
	setAsm := (self pdl: aPDL) parse: setAsmSource.
	instruction := aPDL instructions at: instructionName.
	instruction addMnemonic: setAsm.
	setAsm source: setAsmSource.
	setAsm instruction: instruction.
	aPDL addMnemonic: setAsm assembler 
]

{ #category : #'instance creation' }
AcSetAsmParser class >> processAssociations: aCollectionOfAssociations in: aPDL [
	"Take an array of associations from the instruction name
	to the verbatim set_asm directive, parse them and attach
	them to their instructions in the PDL."
	aCollectionOfAssociations do: [ :ass | self processAssociation: ass in: aPDL ].
]

{ #category : #API }
AcSetAsmParser >> parse: s [
	| quote1 quote2 formatString f opString op |
	quote1 := s indexOf: $".
	quote2 := s indexOf: $" startingAt: quote1+1.
	formatString := s copyFrom: quote1+1 to: quote2-1.
	f := (AcMnemonicFormatParser maps: self pdl maps) parse: formatString.
	f isPetitFailure ifTrue: [ self error ].
	opString := s copyFrom: quote2+1 to: s size.
	op := (AcAsmOperandsParser pdl: self pdl) parse: opString.
	^AcSetAsm
		format: f
		operandsAndConstraints: op
]

{ #category : #accessing }
AcSetAsmParser >> pdl [
	^ pdl
]

{ #category : #accessing }
AcSetAsmParser >> pdl: anObject [
	pdl := anObject.
	^self
]
