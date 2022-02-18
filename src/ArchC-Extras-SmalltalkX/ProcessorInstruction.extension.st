Extension { #name : #ProcessorInstruction }

{ #category : #'*ArchC-Extras-SmalltalkX' }
ProcessorInstruction >> asGDBInstruction [
	^ GDBInstruction new
		propertyAt: #address put: nil;
		propertyAt: #opcodes put: ([ self asByteArray ] on: MustBeConcrete do: [ ByteArray new: self width // 8 ]);
		propertyAt: #inst put: self disassemble;
		propertyAt: #dissection put: (isa architectureName = 'riscv64' ifTrue: [ AcRISCVInstructionDissection for: self ] ifFalse: [ nil ]);
		yourself
]
