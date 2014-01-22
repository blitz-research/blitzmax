Rem
Null is a BlitzMax Constant representing an empty Object reference.
End Rem

Type mytype
	Field	atypevariable
End Type

Global a:mytype

if a=null Print "a is uninitialized"
a=new mytype
if a<>null Print "a is initialized"