Class {
	#name : #MdwnInstruction,
	#superclass : #Object,
	#instVars : [
		'desc',
		'form',
		'opcodes',
		'pcode',
		'sregs'
	],
	#category : #'ArchC-LibreSOC'
}

{ #category : #accessing }
MdwnInstruction >> desc [
	^ desc
]

{ #category : #accessing }
MdwnInstruction >> desc: anObject [
	desc := anObject
]

{ #category : #accessing }
MdwnInstruction >> form [
	^ form
]

{ #category : #accessing }
MdwnInstruction >> form: anObject [
	form := anObject
]

{ #category : #accessing }
MdwnInstruction >> opcodes [
	opcodes isNil ifTrue: [ opcodes := OrderedCollection new ].
	^ opcodes
]

{ #category : #accessing }
MdwnInstruction >> opcodes: anObject [
	opcodes := anObject
]

{ #category : #accessing }
MdwnInstruction >> pcode [
	pcode isNil ifTrue: [ pcode := OrderedCollection new ].
	^ pcode
]

{ #category : #accessing }
MdwnInstruction >> pcode: anObject [
	pcode := anObject
]

{ #category : #accessing }
MdwnInstruction >> sregs [
	sregs isNil ifTrue: [ sregs := OrderedCollection new ].
	^ sregs
]

{ #category : #accessing }
MdwnInstruction >> sregs: anObject [
	sregs := anObject
]
