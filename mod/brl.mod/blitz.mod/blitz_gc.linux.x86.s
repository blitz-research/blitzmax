
	format	ELF

	public	bbGCRootRegs
	
	section	"code"

	;0[esp]=ret
	;4[esp]=buf
bbGCRootRegs:
	mov		eax,[esp+4]
	mov		[eax],ebx
	mov		[eax+4],esi
	mov		[eax+8],edi
	mov		[eax+12],ebp
	mov		eax,esp
	add		eax,8
	ret
