Rem
Function marks the beginning of a BlitzMax function declaration.

When a function does not return a value the use of brackets when
calling the function is optional.
End Rem

Function NextArg(a$)
	Local	p
	p=instr(a$,",")
	if p 
		NextArg a$[p..]
		print a$[..p-1]
	else
		print a$
	endif
End Function

NextArg("one,two,three,four")

NextArg "22,25,20"	'look ma, no brackets
