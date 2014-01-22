
    .globl  _bbArgp
	.globl	__bbExEnter
	.globl	__bbExThrow

	.text

_bbArgp:
#   ;0[esp]=our ret
#   ;4[esp]=offset arg
#	;0[ebp]=caller oldebp
#	;4[ebp]=caller ret
#	;8[ebp]=caller first arg!
	lea		8(%ebp),%eax
    add     4(%esp),%eax
	ret

#	;0[esp]=ret
#	;4[esp]=state block
__bbExEnter:
	mov		4(%esp),%edx
#	;
	mov		%ebx,(%edx)
	mov		%esi,4(%edx)
	mov		%edi,8(%edx)
	mov		%ebp,12(%edx)
#	;
	mov		(%esp),%ecx
	mov		%esp,16(%edx)
	mov		%ecx,20(%edx)
#	;
	xor		%eax,%eax
	ret

#	;0[esp]=ret
#	;4[esp]=state block
#	;8[esp]=throw value
__bbExThrow:
	mov		4(%esp),%edx
	mov		8(%esp),%eax
#	;
	mov		12(%edx),%ebp
	mov		8(%edx),%edi
	mov		4(%edx),%esi
	mov		(%edx),%ebx
#	;
	mov		20(%edx),%ecx
	mov		16(%edx),%esp
	add		$4,%esp
	jmp		%ecx
