Class {
	#name : #AcDSLOperandList,
	#superclass : #Array,
	#type : #variable,
	#category : #'ArchC-DSL'
}

{ #category : #adding }
AcDSLOperandList >> , anotherOperand [
	^ self copyWith: anotherOperand asAcDSLOperand
]

{ #category : #converting }
AcDSLOperandList >> asAcDSLOperandList [
	^ self
]

{ #category : #accessing }
AcDSLOperandList >> relocation [
	| reloc |

	reloc := nil.
	self do: [:each |
		each relocation notNil ifTrue: [
			self assert: reloc isNil description: 'Multiple relocation entries'.
			reloc := each relocation.
		].
	].
	^ reloc
]
