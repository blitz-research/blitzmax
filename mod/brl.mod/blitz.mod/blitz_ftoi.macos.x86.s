	.globl	_bbFloatToInt

	.text

#	;0[esp]=ret
#	;4[esp]=double
_bbFloatToInt:
	fldl	4(%esp)
	sub	$12,%esp
	fistl	(%esp)
	fsts	4(%esp)
	fisubl	(%esp)
	fstps	8(%esp)
	pop	%eax
	pop	%ecx
	pop	%edx
	test	%ecx,%ecx
	js	negative
	add	$0x7fffffff,%edx
	sbb	$0,%eax
	ret
negative:
	xor	%ecx,%ecx
	test	%edx,%edx
	setg	%cl
	add	%ecx,%eax
	ret
