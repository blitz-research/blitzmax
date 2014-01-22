
	format	ELF

	public	_bbExEnter
	public	_bbExThrow

	section	"code"

	;0[esp]=ret
	;4[esp]=state block
_bbExEnter:
	mov		edx,[esp+4]
	;
	mov		[edx+0],ebx
	mov		[edx+4],esi
	mov		[edx+8],edi
	mov		[edx+12],ebp
	;
	mov		ecx,[esp]
	mov		[edx+16],esp
	mov		[edx+20],ecx
	;
	xor		eax,eax
	ret

	;0[esp]=ret
	;4[esp]=state block
	;8[esp]=throw value
_bbExThrow:
	mov		edx,[esp+4]
	mov		eax,[esp+8]
	;
	mov		ebp,[edx+12]
	mov		edi,[edx+8]
	mov		esi,[edx+4]
	mov		ebx,[edx+0]
	;
	mov		ecx,[edx+20]
	mov		esp,[edx+16]
	add		esp,4
	jmp		ecx
