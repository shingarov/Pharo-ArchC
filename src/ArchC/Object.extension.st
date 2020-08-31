Extension { #name : #Object }

{ #category : #'*ArchC' }
Object >> disassembleFor: anISA [
	^(anISA decodeableFormFor: self) decodeFor: anISA
]
