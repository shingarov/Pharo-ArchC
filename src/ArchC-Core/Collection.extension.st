Extension { #name : #Collection }

{ #category : #'*ArchC-Core' }
Collection >> decodeFor: anISA [ 
	^self collect: [ :x | x decodeFor: anISA ]
]
