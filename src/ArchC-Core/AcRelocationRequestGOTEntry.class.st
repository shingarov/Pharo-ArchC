"
An `AcRelocationRequestGOTEntry` query is used by individual
relocations to request an GOT entry for given symbol:

	gotentry := AcRelocationRequestGOTEntry query: self

The response (`gotentry` in the above example) is an association from
GOT entry symbol to its address (that is, address of the entry). Actual
allocation of GOT entries is the responsibility of the linker.

See also `AcRelocationRequestPLTEntry`

"
Class {
	#name : #AcRelocationRequestGOTEntry,
	#superclass : #AcRelocationQuery,
	#category : #'ArchC-Core-Relocations'
}
