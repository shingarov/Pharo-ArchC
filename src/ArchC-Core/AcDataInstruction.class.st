Class {
	#name : #AcDataInstruction,
	#superclass : #AcInstruction,
	#instVars : [
		'isa',
		'binaryEncoding',
		'relocation'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #queries }
AcDataInstruction class >> isAbstract [
	^ self == AcDataInstruction.
]

{ #category : #'instance creation' }
AcDataInstruction class >> value: value [
	self assert: self isAbstract not description: 'Cannot instantiate abstract class'.

	^ self basicNew
		value: value;
		yourself.
]

{ #category : #accessing }
AcDataInstruction >> binaryEncoding [
	^ binaryEncoding
]

{ #category : #accessing }
AcDataInstruction >> isa [
	^ isa
]

{ #category : #accessing }
AcDataInstruction >> isa: anAcProcessorDefinition [
	self assert:(isa isNil or: [ anAcProcessorDefinition == isa ]).

	isa := anAcProcessorDefinition.
]

{ #category : #accessing }
AcDataInstruction >> relocation [
	^ relocation
]

{ #category : #accessing }
AcDataInstruction >> relocation: anAcRelocationOrNil [
	"Set or clear relocation entry associated with this instruction."

	self assert: (anAcRelocationOrNil isNil or: [ anAcRelocationOrNil isAcRelocation ]).
	self assert: (anAcRelocationOrNil isNil or: [ anAcRelocationOrNil isValidForInstruction: self])
		 description: 'Invalid data relocation'.
	self assert: (relocation isNil or: [ anAcRelocationOrNil isNil ])
		 description: 'A relocation already associated'.

	relocation := anAcRelocationOrNil
]

{ #category : #accessing }
AcDataInstruction >> value [
	^ self subclassResponsibility
]

{ #category : #accessing }
AcDataInstruction >> value: value [
	^ self subclassResponsibility
]
