Rem
Var is a composite type containing a reference to a variable of the 
specified Type.
End Rem

' the following illustrates parsing function parameters by reference

Function ReturnMultiplevalues(a Var,b Var,c Var)
	a=10
	b=20
	c=30
	Return
End Function

Local x,y,z

ReturnMultipleValues(x,y,z)

Print "x="+x	'10
Print "y="+y	'20
Print "z="+z	'30
