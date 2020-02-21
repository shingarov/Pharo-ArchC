Extension { #name : #Int }

{ #category : #'*ArchC' }
Int >> disassembleFor: anISA [
	^anISA disassembleInt: self
]
