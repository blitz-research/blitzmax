
	.globl  __bbExEnter
	.globl  __bbExThrow
	
	.text
	
	;inputs:
	;r3 = state block
__bbExEnter:
	stmw	r13,0(r3)
	stfd	f14,76(r3)
	stfd	f15,84(r3)
	stfd	f16,92(r3)
	stfd	f17,100(r3)
	stfd	f18,108(r3)
	stfd	f19,116(r3)
	stfd	f20,124(r3)
	stfd	f21,132(r3)
	stfd	f22,140(r3)
	stfd	f23,148(r3)
	stfd	f24,156(r3)
	stfd	f25,164(r3)
	stfd	f26,172(r3)
	stfd	f27,180(r3)
	stfd	f28,188(r3)
	stfd	f29,196(r3)
	stfd	f30,204(r3)
	stfd	f31,212(r3)
	;
	mflr	r0
	stw		r1,220(r3)
	stw		r0,224(r3)
	li		r3,0
	blr
	
	;inputs:
	;r3 = state block
	;r4 = Return value
__bbExThrow:
	lfd		f31,212(r3)
	lfd		f30,204(r3)
	lfd		f29,196(r3)
	lfd		f28,188(r3)
	lfd		f27,180(r3)
	lfd		f26,172(r3)
	lfd		f25,164(r3)
	lfd		f24,156(r3)
	lfd		f23,148(r3)
	lfd		f22,140(r3)
	lfd		f21,132(r3)
	lfd		f20,124(r3)
	lfd		f19,116(r3)
	lfd		f18,108(r3)
	lfd		f17,100(r3)
	lfd		f16,92(r3)
	lfd		f15,84(r3)
	lfd		f14,76(r3)
	lmw		r13,0(r3)
	;
	lwz		r0,224(r3)
	lwz		r1,220(r3)
	mr		r3,r4
	mtlr	r0
	blr
