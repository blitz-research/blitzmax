Rem
Method marks the beginning of a BlitzMax custom type member function.
End Rem

Type TPoint
	field	x,y

	Method ToString$()
		return x+","+y
	End Method
End Type

a:TPoint=new TPoint
print a.ToString()
	