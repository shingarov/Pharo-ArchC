Class {
	#name : #AcRISCVISALimits,
	#superclass : #SharedPool,
	#classVars : [
		'RISCV_BIGIMM_BITS',
		'RISCV_BIGIMM_MAX',
		'RISCV_BIGIMM_MIN',
		'RISCV_BIGIMM_SHIFT',
		'RISCV_IMM_BITS',
		'RISCV_IMM_MAX',
		'RISCV_IMM_MIN',
		'RISCV_IMM_SHIFT'
	],
	#category : #'ArchC-RISCV-Utilities'
}

{ #category : #initialization }
AcRISCVISALimits class >> initialize [
	RISCV_IMM_BITS := 12.
	RISCV_IMM_SHIFT := 32 - RISCV_IMM_BITS.
	RISCV_IMM_MIN := -16r800.
	RISCV_IMM_MAX :=  16r7FF.

	RISCV_BIGIMM_BITS := 32 - RISCV_IMM_BITS.
	RISCV_BIGIMM_SHIFT := 32 - RISCV_BIGIMM_BITS.
	RISCV_BIGIMM_MIN := -16r80000.
	RISCV_BIGIMM_MAX :=  16r7FFFF.
]
