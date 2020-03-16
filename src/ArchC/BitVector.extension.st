Extension { #name : #BitVector }

{ #category : #'*ArchC' }
BitVector >> disassembleFor: anISA [
	^anISA disassembleInt: self
]
