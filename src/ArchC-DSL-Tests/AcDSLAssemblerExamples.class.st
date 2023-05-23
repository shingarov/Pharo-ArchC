Class {
	#name : #AcDSLAssemblerExamples,
	#superclass : #TestCase,
	#category : #'ArchC-DSL-Examples'
}

{ #category : #accessing }
AcDSLAssemblerExamples class >> testSelectors [
	^ self selectors select: [ :each | each beginsWith:'example' ]
]

{ #category : #examples }
AcDSLAssemblerExamples >> example01_ppc32_spinlock [
	| gprs r0 r1 r2 r4 ccrs c0 assembler |

	gprs := AcProcessorDescriptions powerpc64 maps at: 'reg'.
	r0 := AcDSLRegister value: (gprs lookup: '0').
	r1 := AcDSLRegister value: (gprs lookup: '1').
	r2 := AcDSLRegister value: (gprs lookup: '2').
	"..."
	r4 := AcDSLRegister value: (gprs lookup: '4').
	"..."

	ccrs := AcProcessorDescriptions powerpc64 maps at: 'ccr'.
	c0 := AcDSLRegister value: (ccrs lookup: 'cr0'). 

	assembler := AcDSLPPC32Assembler new.
	assembler 
		addi:  r1, r0, 1;
	  label:'restart';
		lwz:  r2, (r4 + 12);
		cmpw: c0, r2, r1;        
		bgt:  c0, (AcDSLSymbol value:'restart');
		blr.

	assembler memory.

	assembler memory fixupBranchTargets.

	assembler memory.
]
