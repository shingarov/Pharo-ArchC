Extension { #name : #Object }

{ #category : #'*ArchC' }
Object >> disassembleFor: anISA [
	^(anISA disassembleableFormFor: self) disassembleFor: anISA
]
