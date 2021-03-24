Extension { #name : #RBMethodNode }

{ #category : #'*ArchC-Extras-Pharo' }
RBMethodNode >> assemblyISA [
	self pragmas do: [ :p | p assemblyISA ifNotNil: [ :isa | ^isa ] ].
	^nil

]
