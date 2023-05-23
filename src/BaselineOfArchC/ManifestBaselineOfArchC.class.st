Class {
	#name : #ManifestBaselineOfArchC,
	#superclass : #PackageManifest,
	#category : #'BaselineOfArchC-Manifest'
}

{ #category : #'stx - description' }
ManifestBaselineOfArchC class >> includedInPreRequisites [
	"list packages which are to be implicitely included in the prerequisites list,
	 even if not found by the automatic search.
	 Redefine this, if classes from other packages are referred to via reflection
	 or by constructing names dynamically (i.e. the search cannot find it)"  

	^ #(
		#'BaselineOfMachineArithmetic'
		#'ArchC-Core'
		#'ArchC-RISCV'
		#'ArchC-DSL'
		#'ArchC-Core-Tests'
		#'ArchC-RISCV-Tests'
		#'ArchC-DSL-Tests'
	)
]

{ #category : #'stx - description' }
ManifestBaselineOfArchC class >> mandatoryPreRequisites [
	"list packages which are mandatory as a prerequisite.
	 This are packages containing superclasses of my classes and classes which
	 are extended by myself.
	 They are mandatory, because we need these packages as a prerequisite for loading and compiling.
	 This method is generated automatically,
	 by searching along the inheritance chain of all of my classes.
	 Please take a look at the #referencedPreRequisites method as well."

	^ #(
		#'stx:libbasic'    "Object - superclass of BaselineOfArchC"
		#'stx:libcompat'    "BaselineOf - superclass of BaselineOfArchC"
	)
]
