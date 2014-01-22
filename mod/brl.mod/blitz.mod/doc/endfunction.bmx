Rem
Function marks the end of a BlitzMax function declaration.
End Rem

Function RandomName$()
	local a$[]=["Bob","Joe","Bill"]
	Return a[Rnd(Len a)]
End Function

For i=1 To 5
	Print RandomName$()
Next
