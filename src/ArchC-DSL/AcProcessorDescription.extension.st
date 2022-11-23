Extension { #name : #AcProcessorDescription }

{ #category : #'*ArchC-DSL' }
AcProcessorDescription >> assembleDSL: mnemonic operands: operands [
	self instructions do: [:instruction | 
		instruction syntax do: [:syntax | 
			syntax format operands size = operands size ifTrue: [
				syntax mnemonics do: [:each | 
					mnemonic = each ifTrue: [ 
						^ syntax assembleDSL: mnemonic operands: operands
					].
				].
			].
		].
	].
	self error: 'No instruction with mnemonic ''', mnemonic , ''''
]
