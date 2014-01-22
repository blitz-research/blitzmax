Rem
New creates a BlitzMax variable of the Type specified.
End Rem

Type MyType
	Field	a,b,c
End Type

Local t:MyType
t=New MyType
t.a=20

print t.a

' if a new method is defined for the type it will also be called

Type MyClass
	Field	a,b,c
	Method New()
		print "Constructor invoked!"
		a=10
	End Method
End Type

Local c:MyClass
c=new MyClass
print c.a
