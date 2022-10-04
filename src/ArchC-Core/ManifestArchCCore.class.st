Class {
	#name : #ManifestArchCCore,
	#superclass : #PackageManifest,
	#category : #'ArchC-Core-Manifest'
}

{ #category : #'stx - private' }
ManifestArchCCore class >> effectivePreRequisites [
	"Overidden to automagically add MachineArithmetic if
	 no there's no class BitVector. This allows using alternative
	 BitVector implementation."

	| prereqs |

	prereqs := super effectivePreRequisites.
	(Smalltalk includesKey: #BitVector) ifFalse: [
		prereqs add: 'BaselineOfMachineArithmetic'
	].
	^ prereqs
]

{ #category : #'stx - description' }
ManifestArchCCore class >> excludedFromMandatoryPreRequisites [
	"List packages which are to be explicitely excluded from the automatic constructed
	 prerequisites lists (both).
	 If empty, everything that is found along the inheritance of any of
	 my classes is considered to be a prerequisite package."

	^ #(
		#'stx:libview'       "Form - referenced by AcProcessorDescription class>>systemIcon"
		#'MachineArithmetic-FFI-SmalltalkX'    "Z3Object - extended"
		#'MachineArithmetic' "MachineArithmetic is added dynamically when no BitVector class is present,
							  see #effectivePreRequisites."
		#'BitVector'         "Alternative implementation of BitVector shipped with ArchC."
	)
]

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
		#'stx:goodies/petitparser'    "PPCompositeParser - superclass of AcAbiParser"
		#'stx:libbasic'    "ArrayedCollection - extended"
		#'stx:libcompat'    "PackageManifest - superclass of ManifestArchCCore"
	)
]

{ #category : #'stx - description' }
ManifestArchCCore class >> referencedPreRequisites [
	"list packages which are a prerequisite, because they contain
	 classes which are referenced by my classes.
	 These packages are NOT needed as a prerequisite for compiling or loading,
	 however, a class from it may be referenced during execution and having it
	 unloaded then may lead to a runtime doesNotUnderstand error, unless the caller
	 includes explicit checks for the package being present.
	 This method is generated automatically,
	 by searching all classes (and their packages) which are referenced by my classes.
	 Please also take a look at the #mandatoryPreRequisites method"

	^ #(
	)
]
