
	.globl  _bbGCRootRegs

	.text

	;inputs:
	;r3 = state block
_bbGCRootRegs:
	stmw	r13,0(r3)
	addi	r3,r1,0
	blr
