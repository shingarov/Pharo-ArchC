Extension { #name : #BitVector }

{ #category : #'*ArchC' }
BitVector >> decodeFor: anISA [
	^anISA decodeInt: self
]
