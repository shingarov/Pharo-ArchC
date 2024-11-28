"
An `AcRelocationRequestPLTEntry` query is used by individual
relocations to request an PLT (trampoline) entry for given symbol:

	pltentry := AcRelocationRequestPLTEntry query: self

The response (`pltentry` in the above example) is an association from
PLT entry symbol to its address (that is, address of the entry). Actual
allocation of PLT entries is the responsibility of the linker.

See also `AcRelocationRequestGOTEntry`

"
Class {
	#name : #AcRelocationRequestPLTEntry,
	#superclass : #AcRelocationQuery,
	#category : #'ArchC-Core-Relocations'
}
