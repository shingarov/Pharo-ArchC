"
I represent one line of an ac_asm_map.
These are interesting on SPARC, where r8..r15 is o0..o7, etc.
Lines are later combined.

I (bgs) forget what the status of implementing this, currently is;
I remember I had tests for this, and on PowerPC this was used for traps,
but somehow this class is unreferenced.

"
Class {
	#name : #AcAsmMapBody,
	#superclass : #Object,
	#category : #'ArchC-Parsing'
}
