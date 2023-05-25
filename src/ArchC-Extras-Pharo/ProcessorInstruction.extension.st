Extension { #name : #ProcessorInstruction }

{ #category : #'*ArchC-Extras-Pharo' }
ProcessorInstruction >> gtInspectorOperandsIn: composite [
	<gtInspectorPresentationOrder: 15>
	composite fastTable
		title: 'Operands';
		display: [ self externalBindings associations ];
		column: 'Op' evaluated: [ :each | each key ];
		column: 'Value' evaluated: [ :each | each value ]
]

{ #category : #'*ArchC-Extras-Pharo' }
ProcessorInstruction >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: 20>
	composite morph
		title: 'Bit fields';
		morph: [ InstructionMorph on: self ]
]
