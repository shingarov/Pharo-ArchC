Class {
	#name : #AcDSLAssemblerGenerator,
	#superclass : #Object,
	#instVars : [
		'assemblerClass'
	],
	#category : #'ArchC-DSL'
}

{ #category : #utilities }
AcDSLAssemblerGenerator class >> generate: aClass [
	AcProcessorDescriptions reset.
	self new generate: aClass
]

{ #category : #utilities }
AcDSLAssemblerGenerator >> generate [
	| isa |

	isa := assemblerClass isa.
	isa instructions do: [:each | self generateForInstruction: each ].
	assemblerClass generated: true.
]

{ #category : #utilities }
AcDSLAssemblerGenerator >> generate: aClass [
	assemblerClass := aClass.
	self generate
]

{ #category : #utilities }
AcDSLAssemblerGenerator >> generateForInstruction: aProcessorInstructionDeclaration [
	| sourceTemplateNargs sourceTemplate0args |

	sourceTemplateNargs := 
'<1s> operands
	"Automatically generated, do not edit!"
	%<synthetic%>

	^ self append: ''<2s>'' operands: operands
'.

	sourceTemplate0args := 
'<1s>
	"Automatically generated, do not edit!"
	%<synthetic%>

	^ self append: ''<2s>'' operands: #()
'.                                                 

	aProcessorInstructionDeclaration syntax do: [:syntax | 
		syntax mnemonics do: [:mnemonic | 
			| selector source  |

			syntax operands notEmpty ifTrue: [
				selector := (mnemonic , ':') replaceAll: $. with: $_.       
				source := sourceTemplateNargs expandMacrosWith: selector with: mnemonic.
			] ifFalse: [ 
				selector := mnemonic replaceAll: $. with: $_.       
				source := sourceTemplate0args expandMacrosWith: selector with: mnemonic.
			].
			assemblerClass compile: source classified: '* generated *'.
		].
	].
]
