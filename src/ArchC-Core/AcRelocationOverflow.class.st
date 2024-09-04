Class {
	#name : #AcRelocationOverflow,
	#superclass : #AcRelocationFailed,
	#category : #'ArchC-Core-Relocations'
}

{ #category : #accessing }
AcRelocationOverflow >> isResumable [
	^ self mayProceed
]

{ #category : #'default actions' }
AcRelocationOverflow >> mayProceed [
	^ true
]
