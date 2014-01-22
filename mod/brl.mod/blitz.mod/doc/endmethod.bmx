Rem
EndMethod marks the end of a BlitzMax Method declaration.
End Rem

Type TPoint
	field	x,y

	Method ToString$()
		return x+","+y
	End Method
End Type

a:TPoint=new TPoint
print a.ToString()
