Rem
Else provides the ability for an If Then construct to execute a second block of code when the If condition is false.
End Rem

i=3

If i<5 Print "i<5" Else Print "i>=5"	' single line If Else

If i<5			'block style If Else
	Print "i<5"
Else
	Print "i>=5"
EndIf

