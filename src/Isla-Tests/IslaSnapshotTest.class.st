Class {
	#name : #IslaSnapshotTest,
	#superclass : #TestCaseWithZ3Context,
	#category : #'Isla-Tests'
}

{ #category : #tests }
IslaSnapshotTest >> testAARCH64 [
	| p |
	p := KluiverParser parseProgram: (FileSystem / '/home/boris/work/REMS/isla-snapshots/aarch64.ir') readStream contents.
	self halt
]

{ #category : #tests }
IslaSnapshotTest >> testDuopod [
	self workFile: '/home/boris/work/REMS/isla-sail-riscv/duopod.ir'
]

{ #category : #tests }
IslaSnapshotTest >> testRISCV64 [
	self workFile: '/home/boris/work/REMS/isla-sail-riscv/riscv64.ir'
]

{ #category : #tests }
IslaSnapshotTest >> workFile: fname [
	| p k |
	p := KluiverParser parseProgram: (FileSystem / fname) readStream contents.
	k := p kluiver.
	self halt
]
