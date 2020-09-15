Extension { #name : #Collection }

{ #category : #'*ArchC' }
Collection >> decodeFor: anISA [ 
	^self collect: [ :x | x decodeFor: anISA ]
]
