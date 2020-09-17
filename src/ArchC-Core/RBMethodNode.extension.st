Extension { #name : #RBMethodNode }

{ #category : #'*ArchC-Core' }
RBMethodNode >> assemblyISA [
	self pragmas do: [ :p | p assemblyISA ifNotNil: [ :isa | ^isa ] ].
	^nil

]
