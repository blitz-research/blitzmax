Rem
SizeOf returns the number of bytes of system memory used to store the variable.
End Rem

Type MyType
	Field a,b,c
End Type

Local t:MyType
print sizeof t	'prints 12

Local f!
print sizeof f	'prints 8

Local i
print sizeof i	'prints 4

Local b:Byte
print sizeof b	'prints 1

a$="Hello World"
print sizeof a	'prints 22 (unicode characters take 2 bytes each)