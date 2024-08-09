Class {
	#name : #AcRelocationQuery,
	#superclass : #Query,
	#instVars : [
		'relocation'
	],
	#category : #'ArchC-Core-Relocations'
}

{ #category : #queries }
AcRelocationQuery class >> isAbstract [
	"Return if this class is an abstract class.
	 True is returned here for myself only; false for subclasses.
	 Abstract subclasses must redefine this again."

	^ self == AcRelocationQuery.
]

{ #category : #queries }
AcRelocationQuery class >> query [
	^ self shouldNotImplement. "Use #query: someRelocation"
]

{ #category : #queries }
AcRelocationQuery class >> query: anAcRelocation [
	self assert: anAcRelocation isAcRelocation.

	^ self new
		relocation: anAcRelocation;
		query
]

{ #category : #'default actions' }
AcRelocationQuery >> defaultResumeValue [
	"If not handled, just throw AcRelocationFailure since we did not get
	 requested data (GOT / TOC entry, PLT and what not)."

	AcRelocationFailed new
			relocation: relocation;
			signal: 'Relocation request failed!'.
	^ nil
]

{ #category : #accessing }
AcRelocationQuery >> relocation [
	^ relocation
]

{ #category : #accessing }
AcRelocationQuery >> relocation: anAcRelocation [
	self assert: anAcRelocation isAcRelocation.

	relocation := anAcRelocation.
]

{ #category : #'handler actions' }
AcRelocationQuery >> resume: symbolAndAddr [
	"Respond to request with given symbol and its (final) address"

	self assert:(symbolAndAddr isKindOf: Association).
	self assert: symbolAndAddr key notNil.
	self assert: symbolAndAddr value isInteger.

	super resume: symbolAndAddr
]

{ #category : #accessing }
AcRelocationQuery >> symbol [
	^ relocation symbol
]
