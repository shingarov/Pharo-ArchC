Class {
	#name : #MdwnParser,
	#superclass : #Object,
	#instVars : [
		'state'
	],
	#category : #'ArchC-LibreSOC'
}

{ #category : #'working directory' }
MdwnParser class >> baseDirectory [
	"Answer where the working copy of LibreSOC is.

	The directory is determined as follows:

	1. environment variable named LIBRESOC,
	   if not set then
	1. `libresoc` directory in local git working copy
	   (as created by `get-libresoc.sh` script)
	"

	| base slash |
	base := 'LIBRESOC' getOSEnvironment.
	base isNil ifTrue:[
		self shouldBeImplemented.
		base := self baseDirectoryGuess.
		base isNil ifTrue:[
			self error: 'Failed to guess the base directory for PDLs, please run `get-libresoc.sh` or set ''LIBRESOC'' environment.'
		].
	].

	"Make sure it has a slash at the end!"
	((Smalltalk respondsTo: #isSmalltalkX) and: [ Smalltalk isSmalltalkX ]) ifTrue: [ 
		slash := #Filename asClass separator
	] ifFalse: [ 
		slash := #DiskStore asClass activeClass delimiter.
	].
	(base notNil and:[base last ~~ slash]) ifTrue:[
		self error: 'Base directory must end with ', slash asString
	].
	^base

	"
	MdwnParser baseDirectory
	"

]

{ #category : #'working directory' }
MdwnParser class >> filenameFor: page [
	^self baseDirectory,
		'openpower-isa/openpower/isa/',
		page,
		'.mdwn'
]

{ #category : #API }
MdwnParser class >> parse: pageName [
	| filename lines |
	filename := self filenameFor: pageName.
	^self new parse: filename asFileReference readStream contents lines.
	
]

{ #category : #initialization }
MdwnParser >> initialize [
	state := ExpectDesc initial
]

{ #category : #API }
MdwnParser >> parse: lines [ 
	^(lines collect: [ :l |
		self transition: l.
		state isAccepting ifTrue: [
			| instr |
			instr := state op.
			state := ExpectDesc initial.
			instr ] ifFalse: [	nil]]) reject: [ :instr | instr isNil ]
]

{ #category : #logic }
MdwnParser >> transition: l [
	state := state transition: l
]
