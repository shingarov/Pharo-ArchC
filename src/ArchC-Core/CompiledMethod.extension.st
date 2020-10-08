Extension { #name : #CompiledMethod }

{ #category : #'*ArchC-Core' }
CompiledMethod >> isASMMethod [
	
	^ self hasProperty: #ISA
]
