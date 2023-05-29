Class {
	#name : #AcDSLAssembler,
	#superclass : #Object,
	#instVars : [
		'memory',
		'annotations'
	],
	#classInstVars : [
		'generated'
	],
	#category : #'ArchC-DSL'
}

{ #category : #private }
AcDSLAssembler class >> generated [
	"Return `true` if DSL methods for assembling instructions
	 have been generated (and therefore the class is ready to
	 be used). If not, return `false`"

	"The comparison to true is important since instvars defaults
	 to nil!"
	^ generated == true
]

{ #category : #private }
AcDSLAssembler class >> generated: aBoolean [
	generated := aBoolean
]

{ #category : #accessing }
AcDSLAssembler class >> isa [
	^ self subclassResponsibility
]

{ #category : #'instance creation' }
AcDSLAssembler class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #accessing }
AcDSLAssembler >> annotations [
	^ annotations
]

{ #category : #accessing }
AcDSLAssembler >> annotations: aCollection [
	"Set a list of annotations to be attached to
	 *every* instruction from now on (until a new
	 list of annotations is set via this method).

	 Given collection may be `nil`.
	"
	annotations := aCollection.
]

{ #category : #'emitting-private' }
AcDSLAssembler >> append: insn [
	insn annotations: annotations.
	memory append: insn.
	^ insn
]

{ #category : #'emitting-private' }
AcDSLAssembler >> append: mnemonic operands: operands [
	| insn |

	insn := self class isa assembleDSL: mnemonic operands: operands asAcDSLOperandList.
	self append: insn.
	^ insn.
]

{ #category : #accessing }
AcDSLAssembler >> cursor: anInteger [
	memory cursor: anInteger
]

{ #category : #inspecting }
AcDSLAssembler >> gtInspectorInstructionsIn: composite [
	<gtInspectorPresentationOrder: 60>
	^memory gtInspectorInstructionsIn: composite

]

{ #category : #initialization }
AcDSLAssembler >> initialize [
	super initialize.

	"Lazy-generate DSL methods here upon first instantiation.
	 This solves three problems: 
	   (i) spares users to think of it and doing it manually
	   (ii) avoids generating assemblers which will never be used.
	   (iii) makes it debuggable if there's an error since this will
		 be called once all the code is loaded (as opposed to 'at some
		 undefined time during package loading').
	"
	self class generated ifFalse: [ 
		AcDSLAssemblerGenerator generate: self class.
	].
	memory := AcDSLCodeBuffer new
]

{ #category : #accessing }
AcDSLAssembler >> isa [
	^ self class isa
]

{ #category : #emitting }
AcDSLAssembler >> label: anObject [
	| insn |

	insn := AcLabel symbol: anObject.
	memory append: insn.
	^ insn
]

{ #category : #accessing }
AcDSLAssembler >> memory [
	^ memory
]
