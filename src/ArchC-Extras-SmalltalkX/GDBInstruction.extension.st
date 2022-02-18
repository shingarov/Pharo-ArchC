Extension { #name : #GDBInstruction }

{ #category : #'*ArchC-Extras-SmalltalkX' }
GDBInstruction >> address: anInteger [
	"A horrible hack for ArchC-Extras-SmalltalkX: when we use VDBInstructionListApplication
	 to show a bunch of `ProcessorInstruction` - they do not have their address set. The address
	 is set later in `VDBInstructionListApplication >> delayedUpdateInternalList`.

	 For usefull computation of #branchTarget we need dissection to know the address,
	 so we set it here too.

	 A horrible hack indeed.
	"

	address := anInteger.
	(dissection notNil and: [ dissection respondsTo: #address: ]) ifTrue: [ 
		dissection address: anInteger
	].

	"Created: / 08-11-2021 / 12:52:28 / Jan Vrany <jan.vrany@labware.com>"
]
