Rem
Continue causes program flow to return to the start of the enclosing While, Repeat or For program loop
End Rem

For i=1 To 20
	If i Mod 2 Continue
	Print i
Next
