Extension { #name : #Object }

{ #category : #'*ArchC' }
Object >> decodeFor: anISA [
	^(anISA decodeableFormFor: self) decodeFor: anISA
]
