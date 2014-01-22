Rem
ElseIf provides the ability to test and execute a section of code if the initial condition failed.
End Rem

age=Int( Input("How old Are You?") )

If age<13
	Print "You are young"
ElseIf age<20
	Print "You are a teen!"
Else
	Print "You are neither young nor a teen"
EndIf
 