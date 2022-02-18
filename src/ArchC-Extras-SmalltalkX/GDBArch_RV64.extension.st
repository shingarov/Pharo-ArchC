Extension { #name : #'GDBArch_RV64' }

{ #category : '*ArchC-Extras-SmalltalkX' }
GDBArch_RV64 >> disassemble1: bytes pc: pc [
	| isa insn |

	isa := AcProcessorDescriptions riscv64.
	^ [
		insn := isa decode: bytes.
		(AcRISCVInstructionDissection for: insn)
			address: pc;
			yourself.
	] on: Error do: [:ex |  
		super disassemble1: bytes pc: pc
	].

	"Created: / 18-11-2021 / 23:58:18 / Jan Vrany <jan.vrany@labware.com>"
]
