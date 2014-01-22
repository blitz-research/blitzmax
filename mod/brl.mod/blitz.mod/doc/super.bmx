Rem
Super evaluates to Self cast to the method's immediate base class.
End Rem

Type TypeA
	Method Report()
		print "TypeA reporting"
	End Method
End Type

Type TypeB extends TypeA
	Method Report()
		Print "TypeB Reporting"
		super.Report()
	End Method
End Type

b:TypeB=new TypeB
b.Report()
