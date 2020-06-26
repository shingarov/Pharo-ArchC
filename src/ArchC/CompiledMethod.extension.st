Extension { #name : #CompiledMethod }

{ #category : #'*ArchC' }
CompiledMethod >> isASMMethod [
	
	^ self hasProperty: #ISA
]
