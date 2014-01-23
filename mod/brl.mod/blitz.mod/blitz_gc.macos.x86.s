
	.globl		_bbGCRootRegs

	.text

_bbGCRootRegs:
	mov		4(%esp),%eax
	mov		%ebx,(%eax)
	mov		%esi,4(%eax)
	mov		%edi,8(%eax)
	mov		%ebp,12(%eax)
	mov		%esp,%eax
	add		$8,%eax
	ret
