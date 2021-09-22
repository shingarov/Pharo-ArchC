"
`AcAsmFormatOperandsChunk` represent an instruction operand list,
separated by comma.

"
Class {
	#name : #AcAsmFormatOperandsChunk,
	#superclass : #AcAsmFormatCompositeChunk,
	#category : #'ArchC-Core-Core'
}

{ #category : #'API - assembly' }
AcAsmFormatOperandsChunk >> assembler [
	| operandAssemblers |

	subchunks isEmpty ifTrue: [ ^ nil asParser ==> [:ignored | #() ] ].

	operandAssemblers := OrderedCollection streamContents: [ :s |
		subchunks do: [:subchunk | s nextPut: subchunk assembler ]
		 separatedBy: [ s nextPut: $, asParser trim ==> [: x | #() ] ]
	].

	^ (PPSequenceParser withAll: operandAssemblers) 
	==> [ :nodes | (nodes reject:#isEmpty) flattened ]

]

{ #category : #'API - disassembly' }
AcAsmFormatOperandsChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	subchunks 
		do: [:each | each disassembleTo: aWriteStream operands: ops inEnvironment: e ]
		separatedBy: [aWriteStream nextPut: $,]

]

{ #category : #'printing & storing' }
AcAsmFormatOperandsChunk >> unparseOn: aStream [            
	subchunks do: [:each | each unparseOn: aStream ]
	 separatedBy: [ aStream nextPut: $, ]
]
