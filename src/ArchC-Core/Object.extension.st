Extension { #name : #Object }

{ #category : #'*ArchC-Core' }
Object >> decodeFor: anISA [
	^(anISA decodeableFormFor: self) decodeFor: anISA
]

{ #category : #'*ArchC-Core' }
Object >> isAcAsmOperandModifier [
	^ false
]
