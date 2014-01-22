Rem
Float is a 32 bit floating point BlitzMax primitive type.
End Rem

Local a:float

a=1

for i=1 to 8
	print a
	a=a*0.1
next

for i=1 to 8
	a=a*10
	print a
next
