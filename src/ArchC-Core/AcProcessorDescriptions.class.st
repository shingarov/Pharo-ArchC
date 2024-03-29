"
I know where to find some example PDL descriptions.
"
Class {
	#name : #AcProcessorDescriptions,
	#superclass : #Object,
	#classInstVars : [
		'cache'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'known processors' }
AcProcessorDescriptions class >> amd64 [
	"BOGUS -- ArchC doesn't have a PDL for AMD64."
	^self processor: 'AMD64' in: 'amd64'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> armv5 [
	"  AcProcessorDescriptions armv5  "
	^self processor: 'arm' in: 'arm'
]

{ #category : #'working directory' }
AcProcessorDescriptions class >> baseDirectory [
	"Return a directory where PDLs are looked up.

	The directory is determined as follows:

	1. environment variable named ARCHC_PDL_DIR,
	   if not set then
	1. `pdl` directory in local git working copy
	   (as created by `get-pdls.sh` script)
	"

	| base slash |
	base := 'ARCHC_PDL_DIR' getOSEnvironment.
	base isNil ifTrue:[
		base := self baseDirectoryGuess.
		base isNil ifTrue:[
			self error: 'Failed to guess the base directory for PDLs, please run `get-pdls.sh` or set ''ARCHC_PDL_DIR'' environment.'
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
	AcProcessorDescriptions baseDirectory
	"

]

{ #category : #'working directory' }
AcProcessorDescriptions class >> baseDirectory: aString [
	"Set directory where to look for PDLs"

	((Smalltalk respondsTo: #isSmalltalkX) and: [ Smalltalk isSmalltalkX ]) ifTrue: [
		#OperatingSystem asClass setEnvironment: 'ARCHC_PDL_DIR' to: aString
	] ifFalse: [
		#OSEnvironment asClass current at: 'ARCHC_PDL_DIR' put: aString
	].

	"
	AcProcessorDescriptions baseDirectory: '/home/jv/Projects/Phoenix/ArchC/pdl/'
	AcProcessorDescriptions baseDirectory
	AcProcessorDescriptions powerpc
	"

]

{ #category : #'working directory' }
AcProcessorDescriptions class >> baseDirectoryGuess [
	"Try to guess where the PDLs might be."


	((Smalltalk respondsTo: #isSmalltalkX) and: [ Smalltalk isSmalltalkX ]) ifTrue: [ 
		(ConfigurableFeatures includesFeature: #Tonel) ifTrue: [ 
			| base |

			base := #TonelRepository asClass discoverPackage: self package.
			base notNil ifTrue: [ 
				"Strip trailing 'src'"
				base := base directory.
			].
			base := base / 'pdl'.
			(base / 'arm') exists ifTrue: [ 
				^ base pathName , (#Filename asClass separator)
			].
		].
	] ifFalse: [ 
		| slash package repo |

		slash := #DiskStore asClass activeClass delimiter.
		package := self package name.
		repo := #IceRepository asClass registry
						detect:[ :each | each loadedPackages contains: [:icep | icep name = package ] ]
						ifNone:[ ^nil ].
		(repo location / 'pdl' / 'arm') exists ifTrue:[
			^(repo location / 'pdl') pathString , slash asString
		].
	].

	^ nil

	"
	AcProcessorDescriptions baseDirectoryGuess
	"

]

{ #category : #cache }
AcProcessorDescriptions class >> cachedProcessors [
	cache isNil ifTrue: [ cache := Dictionary new ].
	^cache
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> knownISAs [
	^#(arm mips powerpc r3000 riscv64 sparc IA32)
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> mips [
	^self processor: 'mips' in: 'mips'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> powerpc [
	<gtExample>
	^self processor: 'powerpc' in: 'powerpc'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> powerpc64 [
	<gtExample>
	^self processor: 'powerpc64' in: 'powerpc'
]

{ #category : #cache }
AcProcessorDescriptions class >> processor: isaName in: dir [
	^self cachedProcessors at: isaName ifAbsentPut: [
		AcArchParser
			processor: isaName
			in: self baseDirectory, dir ]
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> r3000 [
	"  AcProcessorDescriptions r3000  "
	^self processor: 'r3000' in: 'r3000'
]

{ #category : #cache }
AcProcessorDescriptions class >> reset [ 
	cache := nil
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> sparcv8 [
	"  AcProcessorDescriptions sparcv8  "
	^self processor: 'sparc' in: 'sparc'
]

{ #category : #'known processors' }
AcProcessorDescriptions class >> x86 [
	"  AcProcessorDescriptions x86  "
	^self processor: 'IA32' in: 'x86'
]
