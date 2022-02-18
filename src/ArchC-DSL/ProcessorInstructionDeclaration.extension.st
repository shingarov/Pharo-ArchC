Extension { #name : #ProcessorInstructionDeclaration }

{ #category : #'*ArchC-DSL' }
ProcessorInstructionDeclaration >> assembleDSL: mnemonic operands: operandList [   
	self syntax do: [:syntax | 
		(syntax mnemonics includes: mnemonic) ifTrue: [ 
			^ syntax assembleDSL: mnemonic operands: operandList   
		].
	].
	^ self error: 'No syntax for mnemonic ''', mnemonic , ''''.
]
