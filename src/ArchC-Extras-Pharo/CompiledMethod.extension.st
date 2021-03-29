Extension { #name : #CompiledMethod }

{ #category : #'*ArchC-Extras-Pharo' }
CompiledMethod >> isASMMethod [
	
	^ self hasProperty: #ISA
]
