Extension { #name : #ProcessorInstruction }

{ #category : #'*ArchC-Extras-Pharo' }
ProcessorInstruction >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: 20>
	composite morph
		title: 'Bit fields';
		morph: [ InstructionMorph on: self ]
]
