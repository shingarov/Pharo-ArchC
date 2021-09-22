Class {
	#name : #AcAsmFormatLiteralSpaceChunk,
	#superclass : #AcAsmFormatLiteralTextChunk,
	#category : #'ArchC-Core-Core'
}

{ #category : #'API - assembly' }
AcAsmFormatLiteralSpaceChunk >> assembler [
	^nil asParser trim  ==> [ :token | #() ] 

]
