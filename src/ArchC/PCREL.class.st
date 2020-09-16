Class {
	#name : #PCREL,
	#superclass : #AsmOperandModifier,
	#category : #'ArchC-Parsing'
}

{ #category : #API }
PCREL >> encodeInFields: fs accordingTo: format [
	fs isMultiField
		ifTrue: [ self error ]
		ifFalse: [ ^fs encodeSimpleValue: self x ]
]
