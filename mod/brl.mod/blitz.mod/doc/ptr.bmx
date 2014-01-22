Rem
Ptr is a composite type containing a pointer to a variable of the specified Type.
End Rem

' the following illustrates the use of traditional c style pointers

Local c[]=[1,2,3,4]
Local p:Int Ptr

p=c
Print "pointer 'p' points to:"+p[0]	'1

p:+1
Print "pointer 'p' points to:"+p[0]	'2

p:+1
Print "pointer 'p' points to:"+p[0]	'3

p:+1
Print "pointer 'p' points to:"+p[0]	'4
