Extension { #name : #AcDSLCodeBuffer }

{ #category : #'*ArchC-Extras-SmalltalkX' }
AcDSLCodeBuffer >> inspector2TabMachineCode [
	<inspector2Tab>

	(Smalltalk includesKey: #VDBInstructionListApplication) ifFalse: [ 
		"VDB not loaded, try to load it"
		PackageLoadError ignoreIn: [ Smalltalk loadPackage: 'jv:vdb' ].

		(Smalltalk includesKey: #VDBInstructionListApplication) ifTrue: [
			"  Still not loaded, give up."
			^ nil
		].
	].

	^ (self newInspector2Tab)
		label:'Machine Code';
		priority:50;
		"  view: [ ... ];"
		application: [ #VDBInstructionListApplication asClass new instructionList: (instructions collect: #asGDBInstruction)];
		"  text: [ ... ];"
		yourself
]

{ #category : #'*ArchC-Extras-SmalltalkX' }
AcDSLCodeBuffer >> inspectorExtraAttributes [
	^ super inspectorExtraAttributes
		at: '-disassembly' put: [ self disassembled ];
		yourself
]
