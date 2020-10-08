Class {
	#name : #ClyASMMethodQuery,
	#superclass : #ClyMethodQuery,
	#instVars : [
		'isa'
	],
	#category : #'ArchC-Extras-Pharo'
}

{ #category : #gui }
ClyASMMethodQuery >> decorateMethodGroupTableCell: anItemCellMorph of: groupItem [
	super decorateMethodGroupTableCell: anItemCellMorph of: groupItem.
	
	anItemCellMorph definitionIcon: #tools
]

{ #category : #printing }
ClyASMMethodQuery >> description [
	^'assembler'
]

{ #category : #testing }
ClyASMMethodQuery >> isCorrectISA: aMethod [
	| thisISA |
	thisISA := aMethod propertyAt: #ISA ifAbsent: [ ^false ].
	^thisISA = self isa asString 
]

{ #category : #accessing }
ClyASMMethodQuery >> isa [
	^ isa
]

{ #category : #accessing }
ClyASMMethodQuery >> isa: anObject [
	isa := anObject
]

{ #category : #testing }
ClyASMMethodQuery >> selectsMethod: aMethod [
	^aMethod isASMMethod and: [ self isCorrectISA: aMethod ]
]
