
	format	ELF

	public	bbFloatToInt

	section	"code" ;code

	;0[esp]=ret
	;4[esp]=double
bbFloatToInt:
	fld		qword [esp+4]
	sub		esp,12
	fist	dword [esp]
	fst		dword [esp+4]
	fisub	dword [esp]
	fstp	dword [esp+8]
	pop		eax
	pop		ecx
	pop		edx
	test	ecx,ecx
	js		negative
	add		edx,0x7fffffff
	sbb		eax,0
	ret
negative:
	xor		ecx,ecx
	test	edx,edx
	setg	cl
	add		eax,ecx
	ret
