Extension { #name : #Collection }

{ #category : #'*ArchC' }
Collection >> disassembleFor: anISA [ 
	^self collect: [ :x | x decodeFor: anISA ]
]
