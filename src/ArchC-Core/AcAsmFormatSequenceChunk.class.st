"
`AcAsmFormatSequenceChunk` represent an sequence of chunks. This is used for
example for more complex operands such as memory references.

When assembling (that is, parsing the line of assembly) it allows for spaces
between subchunks - this it to allow parsing - say - '0x8 ( x0 )' (note the spaces)
even if the format in PDL is specified as ""%exp(%gpr)"".

Note, that according to (arguable out of date) ArchC manual, spaces in between
""tokens"" are allowed and are optional. At least this is my (JV's) interpretation.

"
Class {
	#name : #AcAsmFormatSequenceChunk,
	#superclass : #AcAsmFormatCompositeChunk,
	#category : #'ArchC-Core-Core'
}

{ #category : #'API - assembly' }
AcAsmFormatSequenceChunk >> assembler [
	subchunks isEmpty ifTrue: [ ^ nil asParser ==> [:ignored | #() ] ].

	^ (PPSequenceParser withAll: (subchunks collect: [:each | each assembler trim ])) 
	==> [ :nodes | (nodes reject:#isEmpty) flattened ]

]

{ #category : #'API - disassembly' }
AcAsmFormatSequenceChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	subchunks do:[:subchunk | 
		(subchunk disassembleTo: aWriteStream operands: ops inEnvironment: e) ifFalse:[ ^ false ] 
	].
	^ true
]

{ #category : #'printing & storing' }
AcAsmFormatSequenceChunk >> unparseOn: aStream [            
	subchunks do: [:each | each unparseOn: aStream ]
]
