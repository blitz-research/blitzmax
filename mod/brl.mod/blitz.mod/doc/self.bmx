Rem
Self is used in BlitzMax Methods to reference the invoking variable.
End Rem

Type MyClass
	Global	count	
	Field	id
	
	Method new()
		id=count
		count:+1
		ClassList.AddLast(self)	'adds this new instance to a global list		
	End Method
End Type

Global ClassList:TList

classlist=new TList

local c:MyClass

c=new MyClass
c=new MyClass
c=new MyClass

for c=eachin ClassList
	print c.id
next
