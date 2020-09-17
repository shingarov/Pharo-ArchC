Extension { #name : #BitVector }

{ #category : #'*ArchC-Core' }
BitVector >> decodeFor: anISA [
	^anISA decodeInt: self
]
