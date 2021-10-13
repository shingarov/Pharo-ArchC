Extension { #name : #AcProcessorDescription }

{ #category : #'*ArchC-DSL' }
AcProcessorDescription >> assembleDSL: mnemonic operands: operands [
	self instructions do: [:instruction | 
		instruction syntax do: [:syntax | 
			syntax mnemonics do: [:each | 
				mnemonic = each ifTrue: [ 
					^ syntax assembleDSL: mnemonic operands: operands
				].
			].
		].
	].
	self error: 'No instruction with mnemonic ''', mnemonic , ''''
]
