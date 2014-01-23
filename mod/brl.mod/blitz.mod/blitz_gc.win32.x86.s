
	;Note:
	;
	;The bbGCEnter/bbGCLeave stuff below is for the Win32 only dll hack.
	;
	;Need a much nicer way to manage dlls...
	;
	format	MS COFF

	public	_bbGCEnter
	public	_bbGCLeave
	public	_bbGCRootRegs
	
	extrn	_bbGCStackTop
	
	section	"code" code
	
_bbGCEnter:
	mov		[_bbGCStackTop],ebp
	ret
	
_bbGCLeave:
	mov		dword [_bbGCStackTop],0
	ret

	;0[esp]=ret
	;4[esp]=buf
_bbGCRootRegs:
	mov		eax,[esp+4]
	mov		[eax],ebx
	mov		[eax+4],esi
	mov		[eax+8],edi
	mov		[eax+12],ebp
	mov		eax,esp
	add		eax,8
	ret
	
