Class {
	#name : #AcDSLAssembler,
	#superclass : #Object,
	#instVars : [
		'object',
		'cursor',
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
	object instructions add: insn afterIndex: cursor.
	cursor := cursor + 1.
	^ insn
]

{ #category : #'emitting-private' }
AcDSLAssembler >> append: mnemonic operands: operands [
	| insn |

	insn := self class isa assembleDSL: mnemonic operands: operands asAcDSLOperandList.
	self append: insn.
	^ insn.
]

{ #category : #'emitting-private' }
AcDSLAssembler >> appendDC: dataClass operands: operands [
	operands asAcDSLOperandList do: [:operand |
		| data |

		data := dataClass new
					isa: self isa;
					value: operand;
					relocation: operand relocation;
					yourself.
		self append: data
	].
]

{ #category : #'emitting - data' }
AcDSLAssembler >> byte: bytes [
	^ self appendDC: AcByte operands: bytes
]

{ #category : #accessing }
AcDSLAssembler >> cursor: anInteger [
	self assert: anInteger isInteger.
	self assert:(anInteger between: 0 and: object instructions size).

	cursor := anInteger
]

{ #category : #inspecting }
AcDSLAssembler >> gtInspectorInstructionsIn: composite [
	<gtInspectorPresentationOrder: 60>
	^object gtInspectorInstructionsIn: composite
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
	object := AcDSLCodeObject new.
	cursor := 0.
]

{ #category : #'emitting - data' }
AcDSLAssembler >> int16: int16s [
	^ self appendDC: AcInt16 operands: int16s
]

{ #category : #'emitting - data' }
AcDSLAssembler >> int32: int32s [
	^ self appendDC: AcInt32 operands: int32s
]

{ #category : #'emitting - data' }
AcDSLAssembler >> int64: int64s [
	^ self appendDC: AcInt64 operands: int64s
]

{ #category : #accessing }
AcDSLAssembler >> isa [
	^ self class isa
]

{ #category : #emitting }
AcDSLAssembler >> label: anObject [
	| insn |

	insn := AcLabel symbol: anObject.
	self append: insn.
	^ insn
]

{ #category : #accessing }
AcDSLAssembler >> memory [
	<resource: #obsolete>

	^self object
]

{ #category : #accessing }
AcDSLAssembler >> object [
	"Return the code object containing the code generated
	 by this assembler."

	^ object
]
