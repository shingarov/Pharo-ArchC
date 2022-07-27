Extension { #name : #AcDSLAssemblerLabel }

{ #category : #'*ArchC-Extras-SmalltalkX' }
AcDSLAssemblerLabel >> asGDBInstruction [
	^ GDBInstruction new
		propertyAt: #address put: nil;
		propertyAt: #opcodes put: #[];
		propertyAt: #inst put: self disassemble;
		yourself
]
