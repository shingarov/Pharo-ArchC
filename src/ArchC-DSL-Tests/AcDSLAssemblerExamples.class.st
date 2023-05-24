Class {
	#name : #AcDSLAssemblerExamples,
	#superclass : #TestCase,
	#category : #'ArchC-DSL-Tests'
}

{ #category : #accessing }
AcDSLAssemblerExamples class >> testSelectors [
	^ self selectors select: [ :each | each beginsWith:'example' ]
]

{ #category : #examples }
AcDSLAssemblerExamples >> example01_ppc32_spinlock [
	"
	This example shows how to build a simple function using
	DSL assembler.
	"

	| gprs r0 r1 r2 r4 ccrs c0 assembler |

	"
	Instruction operands are represented as (sub)instances
	of AcDSLOperand. Here we create some 'registers' we'll use
	later when generating code.

	Typically, those r0, r1 and so on would pool variables in
	some pool but do not need to.
	"
	gprs := AcProcessorDescriptions powerpc64 maps at: 'reg'.
	r0 := AcDSLRegister value: (gprs lookup: '0').
	r1 := AcDSLRegister value: (gprs lookup: '1').
	r2 := AcDSLRegister value: (gprs lookup: '2').
	"..."
	r4 := AcDSLRegister value: (gprs lookup: '4').
	"..."

	ccrs := AcProcessorDescriptions powerpc64 maps at: 'ccr'.
	c0 := AcDSLRegister value: (ccrs lookup: 'cr0'). 

	"Now we create an instance of assembler for desired
	 architecture - in this case 32-bit PowerPC - ..."
	assembler := AcDSLPPC32Assembler new.

	"...and generate some code:"
	assembler 
		addi:  r1, r0, 1;
	  label:'restart';
		lwz:  r2, (r4 + 12);
		cmpw: c0, r2, r1;        
		bgt:  c0, (AcDSLSymbol value:'restart');
		blr.

	"Above few lines generate following code:

		   PC    INSN
		00000    li 1, 0x1@ha
		00004    lwz 2, 12(4)
		00008    cmpw 0x0, 0x2, 0x1
		0000C    bgt .-0x8
		00010    blr

	 As you can see:
		* selector is instruction mnemonic (as used in assembly language)
		* selector takes either one argument - a sequence of operands - or
		  no argument - if the instruction does not have any operands at all.
		* the operand sequence is created simply by #, (just like exception set
		  for #on:do:)
		* you can use integers for immediates, they're automatically converted
		  to `AcDSLImmediate` instances
		* (basereg + offset) represent a memory reference, it's basivally a shorthand
		  for `AcDSLMemRef base: baseref offset: offset`. As of now, only this addresing
		  mode is supported, we may add more complex ones as needed.
	"

	"Once done, you may access generated instructions by asking for
	 assemblers #memory (an instance of `AcDSLCodeBuffer`). Note, that
	 this memory contains a list of *symbolic* instructions. In this 
	 example, the `bgt` instruction is symbolic, because one of the operand
	 is label symbol."
	assembler memory.

	"We use helper method #fixupBranchTargets to fixup (patch) jump symbolic 
	 targets - this is very common so assembler provides an API for it."
	assembler memory fixupBranchTargets.

	"Now the code contains no symbolic values, so we can ask for #bytes
	 representing the real machine code that can be run on the real 
	 hardware."
	assembler memory
]
