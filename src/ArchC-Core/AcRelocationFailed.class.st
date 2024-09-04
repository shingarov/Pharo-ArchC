Class {
	#name : #AcRelocationFailed,
	#superclass : #Error,
	#instVars : [
		'relocation'
	],
	#category : #'ArchC-Core-Relocations'
}

{ #category : #accessing }
AcRelocationFailed >> relocation [
	^ relocation
]

{ #category : #accessing }
AcRelocationFailed >> relocation: anAcRelocation [
	self assert: anAcRelocation isAcRelocation.

	relocation := anAcRelocation.
]
