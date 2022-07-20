Class {
	#name : #ManifestArchCCore,
	#superclass : #PackageManifest,
	#category : #'ArchC-Core-Manifest'
}

{ #category : #'stx - description' }
ManifestArchCCore class >> mandatoryPreRequisites [
	"list packages which are mandatory as a prerequisite.
	 This are packages containing superclasses of my classes and classes which
	 are extended by myself.
	 They are mandatory, because we need these packages as a prerequisite for loading and compiling.
	 This method is generated automatically,
	 by searching along the inheritance chain of all of my classes.
	 Please take a look at the #referencedPreRequisites method as well."

	^ #(
		#MachineArithmetic    "BitVector - extended"
		#'MachineArithmetic-FFI-SmalltalkX'    "Z3Object - extended"
		#'stx:goodies/petitparser'    "PPCompositeParser - superclass of AcAbiParser"
		#'stx:libbasic'    "ArrayedCollection - extended"
		#'stx:libcompat'    "PackageManifest - superclass of ManifestArchCCore"
	)
]
