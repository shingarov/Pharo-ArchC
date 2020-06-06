Extension { #name : #RBMethodNode }

{ #category : #'*ArchC' }
RBMethodNode >> assemblyISA [
	self pragmas do: [ :p | p assemblyISA ifNotNil: [ :isa | ^isa ] ].
	^nil

]
